// Single-pass canvas compositor. Draws background, then for each layer:
// contact shadows → content → drop shadows → effects.
// Shadows are rendered at canvas level so they never clip at layer bounds.

import Foundation
import CoreGraphics
import HarnessKitScreenshots

/// Renders a `CanvasComposition` into a final image.
///
/// `imageLayerImages` lets callers (notably Framely's package-document
/// exporter) hand in pre-decoded `PlatformImage`s for `.image` layers
/// keyed by `CanvasLayer.id`, instead of relying on the layer's
/// `path` field as a filesystem path. The dict takes priority; if a
/// layer has no entry, the renderer falls back to loading the path
/// from disk so existing non-Framely callers keep working.
public nonisolated func renderCanvas(
    _ composition: CanvasComposition,
    deviceImages: [UUID: PlatformImage] = [:],
    imageLayerImages: [UUID: PlatformImage] = [:],
    backgroundImageCache: PlatformImage? = nil
) -> PlatformImage {
    let canvasSize = composition.size
    guard canvasSize.width > 0, canvasSize.height > 0 else {
        return createImage(size: CGSize(width: 1, height: 1)) { _ in }
    }

    // Phase 1: Background.
    //
    // When `composition.background == nil`, allocate one empty canvas and
    // skip `addBackground` entirely — saves a 30 MB canvas-sized alloc at
    // 4K that the old code burned just to hand a clear bitmap to a
    // function that bailed back to its input. Both
    // `NSImage(size:flipped:drawing:)` on macOS and
    // `UIGraphicsImageRenderer(size:format:)` on UIKit initialize the
    // backing bitmap to clear when the drawing closure is empty, so
    // there's no observable pixel difference.
    var result: PlatformImage
    if let background = composition.background {
        let blank = createImage(size: canvasSize) { _ in }
        result = addBackground(image: blank, background: background, backgroundImageCache: backgroundImageCache)
    } else {
        result = createImage(size: canvasSize) { _ in }
    }

    // Phase 2: Layers (bottom to top)
    //
    // Each iteration reassigns `result` through a cascade of
    // canvas-sized intermediate images (contact shadows → content →
    // corner-radius clip → effects → background color → composite).
    // On macOS those are all `NSImage(size:flipped:drawing:)` returns,
    // which are autoreleased — without the pool below they pile up
    // until the enclosing runloop turn ends, and a sync export on a
    // 4K canvas with 20+ layers was peaking at 10+ GB. Draining after
    // each layer collapses steady-state to "prev `result` + current
    // layer's chain", a few hundred MB instead of N × a few hundred MB.
    for layer in composition.layers where layer.isVisible {
        guard !Task.isCancelled else { break }

        let frame = layer.frame.pixelRect(in: canvasSize)
        guard frame.width > 0, frame.height > 0 else { continue }

        // `result` is read AND written each pass — copy out the
        // current value, do the whole chain inside the pool against a
        // local, and assign back on exit. That keeps only the final
        // composited result alive across the drain; the intermediates
        // (contactShadows output, contentImage, effects, backgroundColor)
        // all release at pool exit.
        result = autoreleasepool {
            var layerResult = result

            let contactShadows = layer.shadows.filter { $0.type == .contact }
            if !contactShadows.isEmpty {
                layerResult = renderContactShadows(onto: layerResult, shadows: contactShadows, layerFrame: frame)
            }

            guard let rendered = renderLayerContent(layer: layer, frame: frame, deviceImages: deviceImages, imageLayerImages: imageLayerImages) else {
                return layerResult
            }
            var contentImage = rendered.image

            // Apply corner radius clipping before effects so blurs and
            // overlays respect the rounded boundary. `.shape` and `.image`
            // already clipped inline during their render pass; only
            // `.device` (caller-provided) and `.text` still need the
            // post-hoc pass.
            if layer.cornerRadius > 0, !rendered.cornerRadiusInlined {
                contentImage = applyCanvasCornerRadius(to: contentImage, radius: layer.cornerRadius)
            }

            var processed = applyCanvasEffects(to: contentImage, effects: layer.effects)

            // Composite background color behind the (possibly clipped)
            // content. Runs after effects so the background sits under
            // blur/fade layers.
            if !layer.backgroundColor.isEmpty {
                processed = applyBackgroundColor(behind: processed, hex: layer.backgroundColor, cornerRadius: layer.cornerRadius, size: frame.size)
            }

            let dropShadows = layer.shadows.filter { $0.type == .drop }
            return compositeLayer(content: processed, onto: layerResult, frame: frame, rotation: layer.frame.rotation, opacity: layer.opacity, dropShadows: dropShadows)
        }
    }

    // Phase 3: Crop
    if let crop = composition.crop {
        result = cropImage(image: result, crop: crop)
    }

    return result
}

// MARK: - Layer Content Rendering

/// Returns `(content, cornerRadiusWasInlined)`. When the renderer
/// controls the `CGContext` (shape, image), the continuous
/// corner-radius clip is applied inline and the caller should skip
/// the post-hoc `applyCanvasCornerRadius` pass. For `.device`
/// (caller-provided bitmap) and `.text` (attributed-string draw
/// whose clip interaction is intentionally kept separate), the
/// caller still needs the post-hoc pass.
func renderLayerContent(
    layer: CanvasLayer,
    frame: CGRect,
    deviceImages: [UUID: PlatformImage],
    imageLayerImages: [UUID: PlatformImage]
) -> (image: PlatformImage, cornerRadiusInlined: Bool)? {
    switch layer.content {
    case .device:
        guard let img = deviceImages[layer.id] else { return nil }
        return (img, false)
    case .text(let string, let style):
        return (renderText(string, style: style, frame: frame), false)
    case .shape(let style):
        return (renderShape(style, frame: frame, cornerRadius: layer.cornerRadius), true)
    case .image(let path, let scale, let offsetX, let offsetY, let contentMode):
        // Caller-provided pre-decoded image (e.g. Framely's per-document
        // `AssetStore`) takes priority. Falls back to filesystem-path
        // load for non-Framely callers that still treat `path` as a
        // real path on disk. ImageIO-downsamples to the layer's target
        // pixel box × 2 (Retina safety) so a 4K user photo dropped into
        // a 200-px layer doesn't burn a 33 MB full-resolution bitmap
        // just to immediately scale down.
        let img: PlatformImage?
        if let provided = imageLayerImages[layer.id] {
            img = provided
        } else {
            img = platformImage(contentsOfFile: path, maxPixelSize: canvasLayerMaxPixelSize(frame))
        }
        guard let img else { return nil }
        let rendered = renderImageContent(
            img, frame: frame, scale: scale, offsetX: offsetX, offsetY: offsetY,
            contentMode: contentMode, cornerRadius: layer.cornerRadius
        )
        return (rendered, true)
    }
}

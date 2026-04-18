// Single-pass canvas compositor. Draws background, then for each layer:
// contact shadows → content → drop shadows → effects.
// Shadows are rendered at canvas level so they never clip at layer bounds.

import Foundation
import CoreGraphics
import CoreImage
import CoreImage.CIFilterBuiltins
import ImageIO
import SwiftUI
import HarnessKitScreenshots
#if canImport(AppKit)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

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

// MARK: - Contact Shadow Rendering

private func renderContactShadows(onto canvas: PlatformImage, shadows: [CanvasLayerShadow], layerFrame: CGRect) -> PlatformImage {
    let canvasSize = imageSize(canvas)
    let canvasRect = CGRect(origin: .zero, size: canvasSize)
    let groups = Dictionary(grouping: shadows) { Int($0.blur * min(layerFrame.width, layerFrame.height) * 100) }

    // Per-group bbox rasterize + blur. Was: canvas-sized bitmap per
    // group (≈ 33 MB each at 4K) composited one at a time via
    // `compositeImages` → N canvas-sized intermediates. Now:
    // bbox-sized bitmaps (typically ≈ 1–4 MB for bezel shadows)
    // drawn directly into one final canvas context.
    struct GroupRender {
        let bbox: CGRect
        let image: CGImage
    }
    var renders: [GroupRender] = []
    renders.reserveCapacity(groups.count)

    for (_, group) in groups {
        guard !Task.isCancelled else { break }
        let blurPx = CGFloat(group[0].blur) * min(layerFrame.width, layerFrame.height)

        struct ShapeRender { let rect: CGRect; let cornerRadius: CGFloat; let color: CGColor }
        let shapeRenders: [ShapeRender] = group.map { shadow in
            let sw = CGFloat(shadow.contactWidth) * layerFrame.width
            let sh = CGFloat(shadow.contactHeight) * layerFrame.height
            let sx = layerFrame.midX - sw / 2
            let sy = layerFrame.midY + CGFloat(shadow.contactY) * layerFrame.height / 2 - sh / 2
            let cr = CGFloat(shadow.contactCornerRadius) * min(sw, sh) / 2
            let color = platformColor(hex: shadow.color, opacity: shadow.opacity).cgColor
            return ShapeRender(rect: CGRect(x: sx, y: sy, width: sw, height: sh), cornerRadius: cr, color: color)
        }

        let shapeUnion = shapeRenders.reduce(CGRect.null) { $0.union($1.rect) }
        guard !shapeUnion.isNull, !shapeUnion.isInfinite else { continue }
        let pad = blurPx > 0 ? ceil(4 * blurPx) : 0
        let bbox = shapeUnion.insetBy(dx: -pad, dy: -pad).intersection(canvasRect)
        guard bbox.width > 0, bbox.height > 0 else { continue }

        let shapesBitmap = createImage(size: bbox.size) { ctx in
            for shape in shapeRenders {
                let localRect = shape.rect.offsetBy(dx: -bbox.origin.x, dy: -bbox.origin.y)
                let path = continuousRoundedRectPath(rect: localRect, radius: shape.cornerRadius)
                ctx.addPath(path)
                ctx.setFillColor(shape.color)
                ctx.fillPath()
            }
        }

        let groupCG: CGImage
        if blurPx > 0 {
            guard let cgInput = cgImage(from: shapesBitmap) else { continue }
            let ciInput = CIImage(cgImage: cgInput)
            let blurredCI: CIImage?
            if #available(macOS 12.0, iOS 15.0, visionOS 1.0, *) {
                let filter = CIFilter.gaussianBlur()
                filter.inputImage = ciInput
                filter.radius = Float(blurPx)
                blurredCI = filter.outputImage
            } else {
                guard let filter = CIFilter(name: "CIGaussianBlur") else { continue }
                filter.setValue(ciInput, forKey: kCIInputImageKey)
                filter.setValue(blurPx, forKey: kCIInputRadiusKey)
                blurredCI = filter.outputImage
            }
            guard let out = blurredCI,
                  let cgOut = SharedCIContext.context.createCGImage(out, from: ciInput.extent) else {
                continue
            }
            groupCG = cgOut
        } else {
            guard let cg = cgImage(from: shapesBitmap) else { continue }
            groupCG = cg
        }
        renders.append(GroupRender(bbox: bbox, image: groupCG))
    }

    guard !renders.isEmpty else { return canvas }
    let capturedRenders = renders
    return createImage(size: canvasSize) { ctx in
        drawImageInContext(canvas, in: canvasRect, context: ctx)
        for r in capturedRenders {
            let bboxImage = platformImage(from: r.image, size: r.bbox.size)
            drawImageInContext(bboxImage, in: r.bbox, context: ctx)
        }
    }
}

// MARK: - Layer Content Rendering

/// Returns `(content, cornerRadiusWasInlined)`. When the renderer
/// controls the `CGContext` (shape, image), the continuous
/// corner-radius clip is applied inline and the caller should skip
/// the post-hoc `applyCanvasCornerRadius` pass. For `.device`
/// (caller-provided bitmap) and `.text` (attributed-string draw
/// whose clip interaction is intentionally kept separate), the
/// caller still needs the post-hoc pass.
private func renderLayerContent(
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

// MARK: - Downsample budget

/// Pixel-size budget for `platformImage(contentsOf:maxPixelSize:)` when
/// loading canvas image content. Uses the frame's long-edge pixel dimension
/// × 2 (Retina safety) so we never force an upscale pass in the subsequent
/// `scale`-multiplied draw. For practical canvases the budget is 1–4k, so
/// a user-supplied 8k photo is decoded at 2–8k instead of 8k full-res —
/// saving tens of MB without visible quality loss.
private func canvasLayerMaxPixelSize(_ frame: CGRect) -> Int {
    let longEdge = max(frame.width, frame.height)
    guard longEdge > 0 else { return 0 }
    return Int(ceil(longEdge * 2))
}

// MARK: - Text Rendering

private func renderText(_ string: String, style: CanvasTextStyle, frame: CGRect) -> PlatformImage {
    let size = frame.size
    return createImage(size: size, flipped: true) { ctx in
        let font = resolveFont(family: style.fontFamily, size: CGFloat(style.fontSize), weight: style.fontWeight, italic: style.isItalic)
        let color = platformColor(hex: style.color, opacity: 1.0)

        #if canImport(AppKit)
        let alignment: NSTextAlignment = switch style.alignment {
        case .left: .left
        case .center: .center
        case .right: .right
        }
        let paragraphStyle = TextRenderCache.paragraphStyle(
            alignment: alignment,
            lineSpacingPx: CGFloat(style.lineSpacing - 1.0) * font.pointSize
        )

        var attributes: [NSAttributedString.Key: Any] = [
            .font: font, .foregroundColor: color, .paragraphStyle: paragraphStyle
        ]
        if style.letterSpacing != 0 { attributes[.kern] = CGFloat(style.letterSpacing) }
        if let shadow = style.shadow {
            attributes[.shadow] = TextRenderCache.shadow(
                colorHex: shadow.color, opacity: shadow.opacity,
                blur: shadow.blur, offsetX: shadow.offsetX, offsetY: shadow.offsetY,
                invertY: true  // AppKit text: positive Y is up, source offsetY is UI-down
            )
        }
        let attrString = NSAttributedString(string: string, attributes: attributes)
        // `attrString.draw(in:)` places the first line's line-box TOP
        // at the draw rect's top, which means the first baseline sits
        // at `font.ascender` below the rect top and the cap tops at
        // `ascender - capHeight` below that — i.e. the font's natural
        // "shoulder" of empty space sits *inside* the layer frame.
        //
        // SwiftUI's `Text` on macOS positions glyphs tighter: the
        // rendered cap tops land visually flush with the Text frame's
        // top edge, so the interactive canvas shows text higher than
        // the exporter's draw-at-top result. To match, we shift the
        // draw rect UPWARD by that shoulder (`ascender - capHeight`)
        // so the ink starts at the rect top instead of the line-box
        // top. The line-box itself extends above the image into
        // negative y, but only empty leading space lives there — no
        // glyphs are clipped.
        let topInset = max(0, font.ascender - font.capHeight)
        // Vertical alignment: slack = authored height minus the
        // text's visible (cap-top-to-line-bottom) height. Without
        // subtracting `topInset` the slack would include the shoulder
        // we just hid, and center/bottom alignment would drift down
        // by that amount.
        let measuredRect = attrString.boundingRect(
            with: CGSize(width: size.width, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading]
        )
        let visibleHeight = max(0, measuredRect.height - topInset)
        let slack = max(0, size.height - visibleHeight)
        let yOffset: CGFloat = switch style.verticalAlignment {
        case .top: 0
        case .center: slack / 2
        case .bottom: slack
        }
        attrString.draw(in: CGRect(
            x: 0,
            y: yOffset - topInset,
            width: size.width,
            height: size.height - yOffset + topInset
        ))
        #else
        let alignment: NSTextAlignment = switch style.alignment {
        case .left: .left
        case .center: .center
        case .right: .right
        }
        let paragraphStyle = TextRenderCache.paragraphStyle(
            alignment: alignment,
            lineSpacingPx: CGFloat(style.lineSpacing - 1.0) * font.pointSize
        )

        var attributes: [NSAttributedString.Key: Any] = [
            .font: font, .foregroundColor: color, .paragraphStyle: paragraphStyle
        ]
        if style.letterSpacing != 0 { attributes[.kern] = CGFloat(style.letterSpacing) }
        if let shadow = style.shadow {
            attributes[.shadow] = TextRenderCache.shadow(
                colorHex: shadow.color, opacity: shadow.opacity,
                blur: shadow.blur, offsetX: shadow.offsetX, offsetY: shadow.offsetY,
                invertY: true
            )
        }

        // Push UIKit graphics context for attributed string drawing.
        // `defer` pairs the pop with the push so any future early-return
        // (e.g. layout math that bails on NaN / non-finite) can't leak
        // a pushed context. UIGraphicsPushContext maintains an internal
        // stack — an unbalanced push is a real leak that survives the
        // enclosing autoreleasepool.
        UIGraphicsPushContext(ctx)
        defer { UIGraphicsPopContext() }
        let attrString = NSAttributedString(string: string, attributes: attributes)
        // Same cap-top alignment + vertical-alignment slack as the
        // AppKit branch — see that block's comment for the full
        // rationale.
        let topInset = max(0, font.ascender - font.capHeight)
        let measuredRect = attrString.boundingRect(
            with: CGSize(width: size.width, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil
        )
        let visibleHeight = max(0, measuredRect.height - topInset)
        let slack = max(0, size.height - visibleHeight)
        let yOffset: CGFloat = switch style.verticalAlignment {
        case .top: 0
        case .center: slack / 2
        case .bottom: slack
        }
        attrString.draw(in: CGRect(
            x: 0,
            y: yOffset - topInset,
            width: size.width,
            height: size.height - yOffset + topInset
        ))
        #endif
    }
}

// MARK: - Shape Rendering

private func renderShape(_ style: CanvasShapeStyle, frame: CGRect, cornerRadius: Double = 0) -> PlatformImage {
    let size = frame.size
    return createImage(size: size) { ctx in
        let rect = CGRect(origin: .zero, size: size)

        // Inline continuous corner-radius clip — saves one extra
        // full-layer bitmap vs. the post-hoc `applyCanvasCornerRadius`
        // pass. Identical output because it uses the same
        // `continuousRoundedRectPath` (SwiftUI
        // `RoundedRectangle(style: .continuous)`).
        if cornerRadius > 0 {
            let cornerPath = continuousRoundedRectPath(rect: rect, radius: CGFloat(cornerRadius))
            ctx.addPath(cornerPath)
            ctx.clip()
        }

        // SVG renders itself — skip the path-based fill/stroke pipeline.
        // Direct CGImageSource path avoids NSImage's TIFF round-trip
        // (same rationale as `_roundedPNG`'s direct path): decoding
        // through `NSImage(data:)` materializes an uncompressed bitmap
        // representation behind the NSImage which is then discarded
        // after the `cgImage(forProposedRect:)` call — wasted ~5–15 MB
        // per SVG layer. CGImageSource gives us the CGImage directly.
        //
        // Leak safety: CGImageSource is CF-bridged and released by ARC
        // when `source` / `cgImage` go out of scope. The size-limit
        // option (`kCGImageSourceThumbnailMaxPixelSize`) bounds decode
        // memory when a caller supplies a huge SVG for a small layer.
        if case .customSVG(let svgString) = style.path {
            if let data = svgString.data(using: .utf8) as CFData?,
               let source = CGImageSourceCreateWithData(data, nil) {
                let maxPixel = Int(ceil(max(rect.width, rect.height) * 2))
                let options: [CFString: Any] = [
                    kCGImageSourceShouldCache: false,
                    kCGImageSourceCreateThumbnailFromImageAlways: true,
                    kCGImageSourceThumbnailMaxPixelSize: maxPixel
                ]
                if let cgImage = CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary) {
                    ctx.draw(cgImage, in: rect)
                }
            }
            return
        }

        // Build CGPath for the shape
        let shapePath: CGPath
        switch style.path {
        case .rectangle(let cr):
            shapePath = continuousRoundedRectPath(rect: rect, radius: CGFloat(cr))
        case .ellipse:
            shapePath = CGPath(ellipseIn: rect, transform: nil)
        case .roundedRectangle(let tl, let tr, let bl, let br):
            shapePath = roundedRectCGPath(rect: rect, topLeft: tl, topRight: tr, bottomLeft: bl, bottomRight: br)
        case .line(let sx, let sy, let ex, let ey):
            let p = CGMutablePath()
            p.move(to: CGPoint(x: rect.width * CGFloat(sx), y: rect.height * CGFloat(sy)))
            p.addLine(to: CGPoint(x: rect.width * CGFloat(ex), y: rect.height * CGFloat(ey)))
            shapePath = p
        case .customSVG:
            return  // handled above; unreachable but satisfies exhaustiveness
        }

        if let fill = style.fill {
            switch fill {
            case .solid(let hex, let opacity):
                ctx.addPath(shapePath)
                ctx.setFillColor(platformColor(hex: hex, opacity: opacity).cgColor)
                ctx.fillPath()
            case .linearGradient(let startHex, let endHex, let angle, let opacity):
                ctx.saveGState()
                ctx.addPath(shapePath)
                ctx.clip()
                drawLinearGradient(in: ctx, rect: rect,
                                   startColor: platformColor(hex: startHex, opacity: opacity),
                                   endColor: platformColor(hex: endHex, opacity: opacity),
                                   angle: CGFloat(angle))
                ctx.restoreGState()
            case .radialGradient(let centerHex, let edgeHex, let opacity):
                ctx.saveGState()
                ctx.addPath(shapePath)
                ctx.clip()
                drawRadialGradient(in: ctx, rect: rect,
                                   centerColor: platformColor(hex: centerHex, opacity: opacity),
                                   edgeColor: platformColor(hex: edgeHex, opacity: opacity))
                ctx.restoreGState()
            case .image(let imgPath, let scale, let offsetX, let offsetY):
                // Same Retina-safe downsample as the image-layer path: a
                // huge asset used as a shape fill still only needs to
                // cover the shape's pixel box.
                if let img = platformImage(contentsOfFile: imgPath, maxPixelSize: canvasLayerMaxPixelSize(frame)) {
                    ctx.saveGState()
                    ctx.addPath(shapePath)
                    ctx.clip()
                    let srcSize = imageSize(img)
                    guard srcSize.width > 0, srcSize.height > 0 else { break }
                    let scaleX = rect.width / srcSize.width
                    let scaleY = rect.height / srcSize.height
                    let baseScale = max(scaleX, scaleY) * CGFloat(scale)
                    let drawW = srcSize.width * baseScale
                    let drawH = srcSize.height * baseScale
                    let drawX = (rect.width - drawW) / 2 + CGFloat(offsetX) * rect.width
                    let drawY = (rect.height - drawH) / 2 + CGFloat(offsetY) * rect.height
                    drawImageInContext(img, in: CGRect(x: drawX, y: drawY, width: drawW, height: drawH), context: ctx)
                    ctx.restoreGState()
                }
            }
        }
        if let strokeHex = style.strokeColor {
            ctx.addPath(shapePath)
            ctx.setStrokeColor(platformColor(hex: strokeHex, opacity: style.strokeOpacity).cgColor)
            ctx.setLineWidth(CGFloat(style.strokeWidth))
            ctx.strokePath()
        }
    }
}

private func roundedRectCGPath(rect: CGRect, topLeft: Double, topRight: Double, bottomLeft: Double, bottomRight: Double) -> CGPath {
    let tl = CGFloat(topLeft), tr = CGFloat(topRight), bl = CGFloat(bottomLeft), br = CGFloat(bottomRight)
    let path = CGMutablePath()
    path.move(to: CGPoint(x: rect.minX + bl, y: rect.minY))
    path.addLine(to: CGPoint(x: rect.maxX - br, y: rect.minY))
    path.addArc(center: CGPoint(x: rect.maxX - br, y: rect.minY + br), radius: br, startAngle: -.pi / 2, endAngle: 0, clockwise: false)
    path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - tr))
    path.addArc(center: CGPoint(x: rect.maxX - tr, y: rect.maxY - tr), radius: tr, startAngle: 0, endAngle: .pi / 2, clockwise: false)
    path.addLine(to: CGPoint(x: rect.minX + tl, y: rect.maxY))
    path.addArc(center: CGPoint(x: rect.minX + tl, y: rect.maxY - tl), radius: tl, startAngle: .pi / 2, endAngle: .pi, clockwise: false)
    path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + bl))
    path.addArc(center: CGPoint(x: rect.minX + bl, y: rect.minY + bl), radius: bl, startAngle: .pi, endAngle: 3 * .pi / 2, clockwise: false)
    path.closeSubpath()
    return path
}

// MARK: - Continuous corner-radius path

/// Returns a rounded-rect `CGPath` using the platform's continuous-curve
/// (superellipse/"squircle") algorithm — equivalent to SwiftUI's
/// `RoundedRectangle(cornerRadius:style:.continuous)`.
/// Delegates to `NSBezierPath` / `UIBezierPath` with `cornerCurve = .continuous`
/// so the shape matches what the interactive canvas shows.
/// Returns a rounded-rect `CGPath` using Apple's continuous-curve
/// (superellipse/"squircle") algorithm, matching SwiftUI's
/// `RoundedRectangle(cornerRadius:style:.continuous)`.
/// Delegates to SwiftUI so the shape is bit-for-bit identical to what
/// the interactive canvas renders.
private func continuousRoundedRectPath(rect: CGRect, radius: CGFloat) -> CGPath {
    ContinuousPathCache.path(rect: rect, radius: radius)
}

// MARK: - Image Content Rendering

private func renderImageContent(_ image: PlatformImage, frame: CGRect, scale: Double, offsetX: Double, offsetY: Double, contentMode: CanvasImageContentMode, cornerRadius: Double = 0) -> PlatformImage {
    let size = frame.size
    return createImage(size: size) { ctx in
        // Inline the continuous corner-radius clip. Saves one full
        // layer-sized allocation vs. `applyCanvasCornerRadius` on a
        // freshly-rendered bitmap. Same `continuousRoundedRectPath` is
        // used — bit-for-bit identical to the post-hoc clip.
        if cornerRadius > 0 {
            let cornerPath = continuousRoundedRectPath(
                rect: CGRect(origin: .zero, size: size),
                radius: CGFloat(cornerRadius)
            )
            ctx.addPath(cornerPath)
            ctx.clip()
        }

        let srcSize = imageSize(image)
        guard srcSize.width > 0, srcSize.height > 0 else { return }
        let scaleX = size.width / srcSize.width
        let scaleY = size.height / srcSize.height
        // `.fit` shrinks until both axes are inside the frame (no
        // clipping required, and the unmatched axis shows empty space).
        // `.fill` grows until both axes cover the frame and overflowing
        // pixels are cropped to the frame rect by the clip below — without
        // the clip the overflow would leak out of the layer's authored
        // bounds when composited later.
        let baseScale: CGFloat
        switch contentMode {
        case .fit:  baseScale = min(scaleX, scaleY) * CGFloat(scale)
        case .fill: baseScale = max(scaleX, scaleY) * CGFloat(scale)
        }
        let drawW = srcSize.width * baseScale
        let drawH = srcSize.height * baseScale
        let drawX = (size.width - drawW) / 2 + CGFloat(offsetX) * size.width
        let drawY = (size.height - drawH) / 2 + CGFloat(offsetY) * size.height
        if contentMode == .fill {
            ctx.saveGState()
            ctx.clip(to: CGRect(origin: .zero, size: size))
        }
        drawImageInContext(image, in: CGRect(x: drawX, y: drawY, width: drawW, height: drawH), context: ctx)
        if contentMode == .fill {
            ctx.restoreGState()
        }
    }
}

// MARK: - Effects

/// Applies a chain of `CanvasLayerEffect`s to `image`.
///
/// Blur/progressive-blur/progressive-fade/colorOverlay stay in
/// `CIImage` space for the whole chain and materialize to a
/// `PlatformImage` once at the end — a four-effect chain used to
/// allocate four canvas-sized bitmaps + four `createCGImage`
/// renders; now it's one. `.cornerRadius` and `.border` are
/// geometric operations without a clean `CIFilter` equivalent
/// (continuous-corner paths, stroked outlines), so they break the
/// fusion: materialize the current `CIImage`, apply the CG-based
/// helper, re-wrap. Callers should place those effects first or
/// last in the chain to keep fusion maximal.
private func applyCanvasEffects(to image: PlatformImage, effects: [CanvasLayerEffect]) -> PlatformImage {
    guard !effects.isEmpty else { return image }
    guard let input = cgImage(from: image) else { return image }

    var ci: CIImage = CIImage(cgImage: input)
    let extent = ci.extent
    let size = imageSize(image)

    for effect in effects {
        ci = applyCanvasEffect(to: ci, effect: effect, extent: extent, size: size)
    }

    guard let out = SharedCIContext.context.createCGImage(ci, from: extent) else {
        return image
    }
    return platformImage(from: out, size: size)
}

private func applyCanvasEffect(
    to ci: CIImage,
    effect: CanvasLayerEffect,
    extent: CGRect,
    size: CGSize
) -> CIImage {
    switch effect {
    case .blur(let radius):
        guard radius > 0 else { return ci }
        return gaussianBlur(ci, radius: radius).cropped(to: extent)

    case .progressiveBlur(let radius, let direction, _, _):
        guard radius > 0 else { return ci }
        // Materialize the blurred pyramid to 8-bit CGImage before the
        // blend. Fusing `gaussianBlur → blendWithMask` in CIImage space
        // keeps float4 through the chain, which diverges from the
        // pre-S3.1 bitmap round-trip by up to ±2 per channel at blur
        // boundaries — enough to break Goldens. Cost: one
        // canvas-sized CGImage alloc per progressiveBlur (same as
        // before; what we saved is the sharp-side round-trip + the
        // mask CGImage round-trip on subsequent effects).
        let blurredCI = gaussianBlur(ci, radius: radius).cropped(to: extent)
        guard let blurredCG = SharedCIContext.context.createCGImage(blurredCI, from: extent) else {
            return ci
        }
        let blurredQuantized = CIImage(cgImage: blurredCG)
        guard let mask = gradientMaskCI(size: size, direction: direction) else { return ci }
        return blendWithMaskCI(sharp: ci, background: blurredQuantized, mask: mask, extent: extent)

    case .progressiveFade(let direction, _, _):
        let transparent = CIImage(color: CIColor.clear).cropped(to: extent)
        guard let mask = gradientMaskCI(size: size, direction: direction) else { return ci }
        return blendWithMaskCI(sharp: ci, background: transparent, mask: mask, extent: extent)

    case .colorOverlay(let hex, let opacity):
        let overlay = CIImage(color: CIColor(cgColor: platformColor(hex: hex, opacity: opacity).cgColor))
            .cropped(to: extent)
        if #available(macOS 12.0, iOS 15.0, visionOS 1.0, *) {
            let blend = CIFilter.sourceAtopCompositing()
            blend.inputImage = overlay
            blend.backgroundImage = ci
            return (blend.outputImage ?? ci).cropped(to: extent)
        } else {
            guard let f = CIFilter(name: "CISourceAtopCompositing") else { return ci }
            f.setValue(overlay, forKey: kCIInputImageKey)
            f.setValue(ci, forKey: kCIInputBackgroundImageKey)
            return (f.outputImage ?? ci).cropped(to: extent)
        }

    case .cornerRadius(let radius):
        // Geometric clip. Materialize, clip (continuous corners need
        // a CGPath), re-wrap as CIImage so subsequent effects fuse.
        guard let cg = SharedCIContext.context.createCGImage(ci, from: extent) else { return ci }
        let clipped = applyCanvasCornerRadius(to: platformImage(from: cg, size: size), radius: radius)
        guard let clippedCG = cgImage(from: clipped) else { return ci }
        return CIImage(cgImage: clippedCG).cropped(to: extent)

    case .border(let hex, let width, let cornerRadius):
        // Stroked outline — no built-in CIFilter. Materialize + re-wrap.
        guard let cg = SharedCIContext.context.createCGImage(ci, from: extent) else { return ci }
        let bordered = applyBorder(
            to: platformImage(from: cg, size: size),
            hex: hex, width: width, cornerRadius: cornerRadius
        )
        guard let borderedCG = cgImage(from: bordered) else { return ci }
        return CIImage(cgImage: borderedCG).cropped(to: extent)
    }
}

private func gaussianBlur(_ ci: CIImage, radius: Double) -> CIImage {
    if #available(macOS 12.0, iOS 15.0, visionOS 1.0, *) {
        let f = CIFilter.gaussianBlur()
        f.inputImage = ci
        f.radius = Float(radius)
        return f.outputImage ?? ci
    } else {
        guard let f = CIFilter(name: "CIGaussianBlur") else { return ci }
        f.setValue(ci, forKey: kCIInputImageKey)
        f.setValue(radius, forKey: kCIInputRadiusKey)
        return f.outputImage ?? ci
    }
}

private func blendWithMaskCI(
    sharp: CIImage,
    background: CIImage,
    mask: CIImage,
    extent: CGRect
) -> CIImage {
    if #available(macOS 12.0, iOS 15.0, visionOS 1.0, *) {
        let blend = CIFilter.blendWithMask()
        blend.inputImage = sharp
        blend.backgroundImage = background
        blend.maskImage = mask
        return (blend.outputImage ?? sharp).cropped(to: extent)
    } else {
        guard let f = CIFilter(name: "CIBlendWithMask") else { return sharp }
        f.setValue(sharp, forKey: kCIInputImageKey)
        f.setValue(background, forKey: kCIInputBackgroundImageKey)
        f.setValue(mask, forKey: kCIInputMaskImageKey)
        return (f.outputImage ?? sharp).cropped(to: extent)
    }
}

/// CIImage-wrapped gradient mask routed through `CIImageCache` so
/// same-key renders across layers and batched export runs dedup.
/// Uses the CG-based renderer underneath to keep pixel output
/// bit-for-bit identical to pre-S3.4 behavior.
private func gradientMaskCI(size: CGSize, direction: ProgressiveBlurDirection) -> CIImage? {
    CIImageCache.linearGradientMask(size: size, direction: direction)
}

func createGradientMask(size: CGSize, direction: ProgressiveBlurDirection) -> PlatformImage {
    createImage(size: size) { ctx in
        let rect = CGRect(origin: .zero, size: size)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let white = CGColor(red: 1, green: 1, blue: 1, alpha: 1)
        let black = CGColor(red: 0, green: 0, blue: 0, alpha: 1)

        let (startColor, endColor, start, end): (CGColor, CGColor, CGPoint, CGPoint) = switch direction {
        case .topToBottom: (white, black, CGPoint(x: rect.midX, y: rect.maxY), CGPoint(x: rect.midX, y: rect.minY))
        case .bottomToTop: (black, white, CGPoint(x: rect.midX, y: rect.maxY), CGPoint(x: rect.midX, y: rect.minY))
        case .leftToRight: (white, black, CGPoint(x: rect.minX, y: rect.midY), CGPoint(x: rect.maxX, y: rect.midY))
        case .rightToLeft: (black, white, CGPoint(x: rect.minX, y: rect.midY), CGPoint(x: rect.maxX, y: rect.midY))
        }

        if let gradient = CGGradient(colorsSpace: colorSpace, colors: [startColor, endColor] as CFArray, locations: [0, 1]) {
            ctx.drawLinearGradient(gradient, start: start, end: end, options: [.drawsBeforeStartLocation, .drawsAfterEndLocation])
        }
    }
}

private func applyCanvasCornerRadius(to image: PlatformImage, radius: Double) -> PlatformImage {
    let size = imageSize(image)
    return createImage(size: size) { ctx in
        let rect = CGRect(origin: .zero, size: size)
        let path = continuousRoundedRectPath(rect: rect, radius: CGFloat(radius))
        ctx.addPath(path)
        ctx.clip()
        drawImageInContext(image, in: rect, context: ctx)
    }
}

/// Fills a rounded-rect background behind `content` and composites the
/// content on top. Used when a `CanvasLayer` carries a `backgroundColor`.
private func applyBackgroundColor(
    behind content: PlatformImage,
    hex: String,
    cornerRadius: Double,
    size: CGSize
) -> PlatformImage {
    let color = platformColor(hex: hex, opacity: 1.0)
    return createImage(size: size) { ctx in
        // Fill background.
        if cornerRadius > 0 {
            let path = continuousRoundedRectPath(rect: CGRect(origin: .zero, size: size), radius: CGFloat(cornerRadius))
            ctx.addPath(path)
            ctx.setFillColor(color.cgColor)
            ctx.fillPath()
        } else {
            ctx.setFillColor(color.cgColor)
            ctx.fill(CGRect(origin: .zero, size: size))
        }
        // Composite content on top.
        drawImageInContext(content, in: CGRect(origin: .zero, size: size), context: ctx)
    }
}

private func applyBorder(to image: PlatformImage, hex: String, width: Double, cornerRadius: Double) -> PlatformImage {
    let size = imageSize(image)
    return createImage(size: size) { ctx in
        let rect = CGRect(origin: .zero, size: size)
        drawImageInContext(image, in: rect, context: ctx)
        let inset = CGFloat(width) / 2
        let borderRect = rect.insetBy(dx: inset, dy: inset)
        let path = continuousRoundedRectPath(rect: borderRect, radius: CGFloat(cornerRadius))
        ctx.addPath(path)
        ctx.setLineWidth(CGFloat(width))
        ctx.setStrokeColor(platformColor(hex: hex, opacity: 1.0).cgColor)
        ctx.strokePath()
    }
}

// MARK: - Layer Compositing

private func compositeLayer(
    content: PlatformImage,
    onto canvas: PlatformImage,
    frame: CGRect,
    rotation: Double,
    opacity: Double,
    dropShadows: [CanvasLayerShadow]
) -> PlatformImage {
    let canvasSize = imageSize(canvas)
    return createImage(size: canvasSize) { ctx in
        drawImageInContext(canvas, in: CGRect(origin: .zero, size: canvasSize), context: ctx)

        ctx.saveGState()

        if rotation != 0 {
            let center = CGPoint(x: frame.midX, y: frame.midY)
            ctx.translateBy(x: center.x, y: center.y)
            ctx.rotate(by: CGFloat(rotation) * .pi / 180)
            ctx.translateBy(x: -center.x, y: -center.y)
        }

        for shadow in dropShadows {
            let refDim = min(frame.width, frame.height)
            ctx.setShadow(
                offset: CGSize(width: CGFloat(shadow.offsetX) * frame.width / 2,
                               height: -CGFloat(shadow.offsetY) * frame.height / 2),
                blur: CGFloat(shadow.blur) * refDim,
                color: platformColor(hex: shadow.color, opacity: shadow.opacity).cgColor
            )
        }

        drawImageInContext(content, in: frame, context: ctx, opacity: CGFloat(opacity))

        ctx.restoreGState()
    }
}

// MARK: - Helpers

private func compositeImages(bottom: PlatformImage, top: PlatformImage) -> PlatformImage {
    let size = imageSize(bottom)
    return createImage(size: size) { ctx in
        let rect = CGRect(origin: .zero, size: size)
        drawImageInContext(bottom, in: rect, context: ctx)
        drawImageInContext(top, in: rect, context: ctx)
    }
}

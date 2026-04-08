//
//  ComposeCanvas.swift
//  HarnessKitTransform
//

import Foundation
#if canImport(AppKit)
import AppKit
import HarnessKitScreenshots

/// A single layer in a multi-device canvas composition.
///
/// - Important: Instances must be created and consumed on the same
///   thread/task. Do not share across concurrent contexts after creation.
public struct CanvasLayer: @unchecked Sendable {
    /// The rendered device image (e.g. output of `applyBezelPipeline`).
    public let image: NSImage
    /// Horizontal offset from canvas center.
    /// 0 = center, -1 = left edge, 1 = right edge (fraction of half-canvas width).
    public let x: CGFloat
    /// Vertical offset from canvas center.
    /// 0 = center, 1 = top edge, -1 = bottom edge (fraction of half-canvas height).
    public let y: CGFloat
    /// Uniform scale applied after fitting the image to the canvas. 1.0 = fill canvas (aspect-fit).
    public let scale: CGFloat

    public init(image: NSImage, x: CGFloat = 0, y: CGFloat = 0, scale: CGFloat = 1.0) {
        self.image = image
        self.x = x
        self.y = y
        self.scale = scale
    }
}

/// Composites multiple device images onto a single canvas.
///
/// Layers are drawn in array order — index 0 at the bottom, last index on top.
/// Each layer's position and scale are relative to the canvas center.
///
/// - Parameters:
///   - layers: Ordered list of layers to composite (bottom to top).
///   - canvasSize: Output canvas dimensions in pixels.
///   - background: Optional background fill drawn behind all layers.
///   - crop: Optional crop rect applied to the final canvas.
public nonisolated func composeCanvas(
    layers: [CanvasLayer],
    canvasSize: NSSize,
    background: ScreenshotBackground? = nil,
    backgroundImageCache: NSImage? = nil,
    crop: CropRect? = nil
) -> NSImage {
    guard canvasSize.width > 0, canvasSize.height > 0 else { return NSImage(size: .zero) }

    var canvas = NSImage(size: canvasSize, flipped: false) { _ in
        if let context = NSGraphicsContext.current {
            context.imageInterpolation = .high
        }
        for layer in layers {
            guard !Task.isCancelled else { break }
            let imgSize = layer.image.size
            guard imgSize.width > 0, imgSize.height > 0 else { continue }
            let fitScale = min(canvasSize.width / imgSize.width, canvasSize.height / imgSize.height)
            let drawW = imgSize.width * fitScale * layer.scale
            let drawH = imgSize.height * fitScale * layer.scale
            let drawX = (canvasSize.width  - drawW) / 2 + layer.x * (canvasSize.width  / 2)
            let drawY = (canvasSize.height - drawH) / 2 + layer.y * (canvasSize.height / 2)
            layer.image.draw(
                in: NSRect(x: drawX, y: drawY, width: drawW, height: drawH),
                from: NSRect(origin: .zero, size: imgSize),
                operation: .sourceOver,
                fraction: 1.0
            )
        }
        return true
    }

    canvas = addBackground(image: canvas, background: background, backgroundImageCache: backgroundImageCache)

    if let crop {
        canvas = cropImage(image: canvas, crop: crop)
    }

    return canvas
}
#endif

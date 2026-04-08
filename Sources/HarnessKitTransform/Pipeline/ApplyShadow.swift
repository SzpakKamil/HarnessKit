//
//  ApplyShadow.swift
//  HarnessKitTransform
//

import Foundation
#if canImport(AppKit)
import AppKit
import CoreImage
import CoreImage.CIFilterBuiltins
import HarnessKitScreenshots

/// Shared CIContext for shadow blur operations — avoids repeated GPU context creation.
private let shadowCIContext = CIContext()

/// Applies an array of shadow effects to the image.
/// Shadows are drawn relative to the composition (device+bezel) positioned on the canvas.
/// The canvas is never expanded — shadows clip to image bounds naturally.
///
/// - Parameter compositionSize: The fitted device composition size on the canvas.
///   All shadow fractions are relative to `min(compositionSize.width, compositionSize.height)`.
/// - Parameter compositionCenter: The center point of the composition on the canvas.
///   Shape shadows are positioned relative to this center.
public nonisolated func applyShadows(
    image: NSImage,
    shadows: [ScreenshotShadow],
    compositionSize: NSSize,
    compositionCenter: NSPoint
) -> NSImage {
    guard !shadows.isEmpty else { return image }

    let canvasSize = image.size
    let refDim = min(compositionSize.width, compositionSize.height)

    // Pre-compute shape shadow geometry to batch by blur radius
    struct ShapeGeometry {
        let rect: NSRect
        let cornerRadius: CGFloat
        let color: NSColor
        let blurPx: CGFloat
    }

    let shapeGeometries: [ShapeGeometry] = shadows.compactMap { shadow in
        guard case .shape(let s) = shadow else { return nil }
        let shadowWidth = CGFloat(s.width) * compositionSize.width
        let shadowHeight = CGFloat(s.height) * compositionSize.height
        let shadowX = compositionCenter.x + CGFloat(s.x) * compositionSize.width / 2 - shadowWidth / 2
        let shadowY = compositionCenter.y + CGFloat(s.y) * compositionSize.height / 2 - shadowHeight / 2
        return ShapeGeometry(
            rect: NSRect(x: shadowX, y: shadowY, width: shadowWidth, height: shadowHeight),
            cornerRadius: CGFloat(s.cornerRadius) * min(shadowWidth, shadowHeight) / 2,
            color: colorFromShadowHex(s.color, opacity: s.opacity),
            blurPx: CGFloat(s.blur) * refDim
        )
    }

    // Group by blur radius so we can batch multiple shapes into one CIFilter pass
    let blurGroups = Dictionary(grouping: shapeGeometries) { Int($0.blurPx * 100) }

    // Pre-render blurred shape shadow composites (one per unique blur radius)
    var blurredComposites: [NSImage] = []
    for (_, shapes) in blurGroups {
        guard !Task.isCancelled else { break }
        let blurPx = shapes[0].blurPx

        if blurPx > 0 {
            let shapeImage = NSImage(size: canvasSize, flipped: false) { _ in
                for shape in shapes {
                    let path = NSBezierPath(roundedRect: shape.rect, xRadius: shape.cornerRadius, yRadius: shape.cornerRadius)
                    shape.color.setFill()
                    path.fill()
                }
                return true
            }
            if let cgInput = shapeImage.cgImage(forProposedRect: nil, context: nil, hints: nil) {
                let ciInput = CIImage(cgImage: cgInput)
                let blurredOutput: CIImage?
                if #available(macOS 12.0, iOS 15.0, *) {
                    let filter = CIFilter.gaussianBlur()
                    filter.inputImage = ciInput
                    filter.radius = Float(blurPx)
                    blurredOutput = filter.outputImage
                } else {
                    guard let filter = CIFilter(name: "CIGaussianBlur") else { continue }
                    filter.setValue(ciInput, forKey: kCIInputImageKey)
                    filter.setValue(blurPx, forKey: kCIInputRadiusKey)
                    blurredOutput = filter.outputImage
                }
                if let output = blurredOutput,
                   let cgBlurred = shadowCIContext.createCGImage(output, from: ciInput.extent) {
                    blurredComposites.append(NSImage(cgImage: cgBlurred, size: canvasSize))
                }
            }
        } else {
            // No blur — draw shapes directly into a composite
            let noBlurImage = NSImage(size: canvasSize, flipped: false) { _ in
                for shape in shapes {
                    let path = NSBezierPath(roundedRect: shape.rect, xRadius: shape.cornerRadius, yRadius: shape.cornerRadius)
                    shape.color.setFill()
                    path.fill()
                }
                return true
            }
            blurredComposites.append(noBlurImage)
        }
    }

    return NSImage(size: canvasSize, flipped: false) { _ in
        // 1. Draw pre-rendered shape shadow composites
        let drawRect = NSRect(origin: .zero, size: canvasSize)
        for composite in blurredComposites {
            composite.draw(in: drawRect, from: drawRect, operation: .sourceOver, fraction: 1.0)
        }

        // 2. Draw drop shadows + image
        for shadow in shadows {
            if case .drop(let d) = shadow {
                let shadowObj = NSShadow()
                shadowObj.shadowColor = colorFromShadowHex(d.color, opacity: d.opacity)
                shadowObj.shadowBlurRadius = CGFloat(d.blur) * refDim
                shadowObj.shadowOffset = NSSize(width: CGFloat(d.offsetX) * compositionSize.width / 2, height: -CGFloat(d.offsetY) * compositionSize.height / 2)
                shadowObj.set()
            }
        }

        image.draw(
            in: NSRect(origin: .zero, size: canvasSize),
            from: NSRect(origin: .zero, size: canvasSize),
            operation: .sourceOver,
            fraction: 1.0
        )
        return true
    }
}

/// Returns the pixel dimensions of an NSImage, ignoring DPI metadata.
/// Use this instead of `image.size` when you need resolution-independent sizing.
/// Falls back to `image.size` for lazily-drawn images (drawing handler) whose
/// representations report `-1` for pixel dimensions.
public nonisolated func pixelSize(of image: NSImage) -> NSSize {
    guard let rep = image.representations.first,
          rep.pixelsWide > 0, rep.pixelsHigh > 0 else {
        return image.size
    }
    return NSSize(width: rep.pixelsWide, height: rep.pixelsHigh)
}

private func colorFromShadowHex(_ hex: String, opacity: Double) -> NSColor {
    let cleaned = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
    var int: UInt64 = 0
    Scanner(string: cleaned).scanHexInt64(&int)
    return NSColor(
        red: CGFloat((int >> 16) & 0xFF) / 255.0,
        green: CGFloat((int >> 8) & 0xFF) / 255.0,
        blue: CGFloat(int & 0xFF) / 255.0,
        alpha: CGFloat(opacity)
    )
}
#endif

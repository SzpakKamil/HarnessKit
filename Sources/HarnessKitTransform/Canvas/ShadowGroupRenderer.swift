import Foundation
import CoreGraphics
import CoreImage
import CoreImage.CIFilterBuiltins

/// One shape to fill inside a shadow group's bbox bitmap.
struct ShadowGroupShape {
    let rect: CGRect
    let cornerRadius: CGFloat
    let color: CGColor
}

/// One rasterized + blurred shadow group, ready for the caller to composite.
struct ShadowGroupRender {
    let bbox: CGRect
    let image: CGImage
}

/// Per-group rasterize-to-bbox + CIGaussianBlur. Shared between the bezel
/// pipeline (`applyShadows`'s shape-shadow loop) and the canvas renderer
/// (`renderContactShadows`).
///
/// For each `(shapes, blurPx)` group:
/// 1. Compute the union of all shape rects, padded by `4σ` of the blur
///    spread (≈ > 99.99% of blur energy at 8-bit quantization), clamped
///    to `canvasRect`.
/// 2. Rasterize the shapes into a bbox-sized bitmap using `pathBuilder`
///    to construct each shape's `CGPath`.
/// 3. If `blurPx > 0`, run a CIGaussianBlur over the bitmap.
/// 4. Append a `ShadowGroupRender` (bbox + the resulting `CGImage`).
///
/// The caller composites the returned renders into its own context — draw
/// order, drop-shadow context state, and the underlying canvas content
/// vary between bezel-path and canvas-path callers, so unifying the
/// composite step too would just push the differences into a switch.
///
/// `pathBuilder` is the seam for the corner-style difference:
/// - bezel pipeline passes `CGPath(roundedRect:cornerWidth:)` (matches
///   the screenshot rounded-corner behavior in the rest of the bezel
///   pipeline);
/// - canvas pipeline passes `continuousRoundedRectPath` (matches SwiftUI
///   `RoundedRectangle(style: .continuous)` in the interactive canvas).
///
/// Cooperative cancellation: returns the renders accumulated so far if
/// the surrounding `Task` is cancelled mid-loop.
func renderShadowGroups(
    _ groups: [(shapes: [ShadowGroupShape], blurPx: CGFloat)],
    canvasRect: CGRect,
    pathBuilder: @escaping @Sendable (_ rect: CGRect, _ cornerRadius: CGFloat) -> CGPath
) -> [ShadowGroupRender] {
    var renders: [ShadowGroupRender] = []
    renders.reserveCapacity(groups.count)

    for group in groups {
        if Task.isCancelled { break }

        let shapeUnion = group.shapes.reduce(CGRect.null) { $0.union($1.rect) }
        guard !shapeUnion.isNull, !shapeUnion.isInfinite else { continue }

        let pad = group.blurPx > 0 ? ceil(4 * group.blurPx) : 0
        let bbox = shapeUnion.insetBy(dx: -pad, dy: -pad).intersection(canvasRect)
        guard bbox.width > 0, bbox.height > 0 else { continue }

        let shapesBitmap = createImage(size: bbox.size) { ctx in
            for shape in group.shapes {
                let localRect = shape.rect.offsetBy(dx: -bbox.origin.x, dy: -bbox.origin.y)
                let path = pathBuilder(localRect, shape.cornerRadius)
                ctx.addPath(path)
                ctx.setFillColor(shape.color)
                ctx.fillPath()
            }
        }

        let groupCG: CGImage
        if group.blurPx > 0 {
            guard let cgInput = cgImage(from: shapesBitmap) else { continue }
            let ciInput = CIImage(cgImage: cgInput)
            let blurredCI: CIImage?
            if #available(macOS 12.0, iOS 15.0, visionOS 1.0, *) {
                let filter = CIFilter.gaussianBlur()
                filter.inputImage = ciInput
                filter.radius = Float(group.blurPx)
                blurredCI = filter.outputImage
            } else {
                guard let filter = CIFilter(name: "CIGaussianBlur") else { continue }
                filter.setValue(ciInput, forKey: kCIInputImageKey)
                filter.setValue(group.blurPx, forKey: kCIInputRadiusKey)
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
        renders.append(ShadowGroupRender(bbox: bbox, image: groupCG))
    }
    return renders
}

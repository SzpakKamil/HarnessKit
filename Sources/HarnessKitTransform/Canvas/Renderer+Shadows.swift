import Foundation
import CoreGraphics
import CoreImage
import CoreImage.CIFilterBuiltins
import HarnessKitScreenshots

// MARK: - Contact Shadow Rendering

func renderContactShadows(onto canvas: PlatformImage, shadows: [CanvasLayerShadow], layerFrame: CGRect) -> PlatformImage {
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

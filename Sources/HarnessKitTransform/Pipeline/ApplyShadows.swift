import Foundation
import CoreGraphics
import CoreImage
import CoreImage.CIFilterBuiltins
import HarnessKitScreenshots

public nonisolated func applyShadows(
    image: PlatformImage,
    shadows: [ScreenshotShadow],
    compositionSize: CGSize,
    compositionCenter: CGPoint
) -> PlatformImage {
    autoreleasepool {
        guard !shadows.isEmpty else { return image }

        let canvasSize = imageSize(image)
        let canvasRect = CGRect(origin: .zero, size: canvasSize)
        let refDim = min(compositionSize.width, compositionSize.height)

        struct ShapeGeometry {
            let rect: CGRect
            let cornerRadius: CGFloat
            let color: CGColor
            let blurPx: CGFloat
        }

        let shapeGeometries: [ShapeGeometry] = shadows.compactMap { shadow in
            guard case .shape(let s) = shadow else { return nil }
            let shadowWidth = CGFloat(s.width) * compositionSize.width
            let shadowHeight = CGFloat(s.height) * compositionSize.height
            let shadowX = compositionCenter.x + CGFloat(s.x) * compositionSize.width / 2 - shadowWidth / 2
            let shadowY = compositionCenter.y + CGFloat(s.y) * compositionSize.height / 2 - shadowHeight / 2
            return ShapeGeometry(
                rect: CGRect(x: shadowX, y: shadowY, width: shadowWidth, height: shadowHeight),
                cornerRadius: CGFloat(s.cornerRadius) * min(shadowWidth, shadowHeight) / 2,
                color: platformColor(hex: s.color, opacity: s.opacity).cgColor,
                blurPx: CGFloat(s.blur) * refDim
            )
        }

        let blurGroups = Dictionary(grouping: shapeGeometries) { Int($0.blurPx * 100) }

        // Per-group we rasterize into a bbox-sized bitmap (shape union
        // padded by 4σ of blur spread, clamped to canvas). Was:
        // canvas-sized bitmap per group — ≈ 33 MB each at 4K. Now:
        // typically ≈ 1–4 MB per group for bezel-sized shadows.
        struct GroupRender {
            let bbox: CGRect
            let image: CGImage
        }
        var renders: [GroupRender] = []
        renders.reserveCapacity(blurGroups.count)

        for (_, shapes) in blurGroups {
            guard !Task.isCancelled else { break }
            let blurPx = shapes[0].blurPx

            let shapeUnion = shapes.reduce(CGRect.null) { $0.union($1.rect) }
            guard !shapeUnion.isNull, !shapeUnion.isInfinite else { continue }
            // 4σ captures > 99.99% of blur energy; at 8-bit quantization
            // the truncated tail is < 1/255 and absorbed by Golden
            // tolerance. No padding when blur == 0.
            let pad = blurPx > 0 ? ceil(4 * blurPx) : 0
            let bbox = shapeUnion.insetBy(dx: -pad, dy: -pad).intersection(canvasRect)
            guard bbox.width > 0, bbox.height > 0 else { continue }

            let shapesBitmap = createImage(size: bbox.size) { ctx in
                for shape in shapes {
                    let localRect = shape.rect.offsetBy(dx: -bbox.origin.x, dy: -bbox.origin.y)
                    let path = CGPath(
                        roundedRect: localRect,
                        cornerWidth: shape.cornerRadius,
                        cornerHeight: shape.cornerRadius,
                        transform: nil
                    )
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

        let capturedRenders = renders
        return createImage(size: canvasSize) { ctx in
            for r in capturedRenders {
                let bboxImage = platformImage(from: r.image, size: r.bbox.size)
                drawImageInContext(bboxImage, in: r.bbox, context: ctx)
            }

            for shadow in shadows {
                if case .drop(let d) = shadow {
                    let shadowColor = platformColor(hex: d.color, opacity: d.opacity).cgColor
                    let offset = CGSize(width: CGFloat(d.offsetX) * compositionSize.width / 2,
                                        height: -CGFloat(d.offsetY) * compositionSize.height / 2)
                    ctx.setShadow(offset: offset, blur: CGFloat(d.blur) * refDim, color: shadowColor)
                }
            }

            drawImageInContext(image, in: canvasRect, context: ctx)
        }
    }
}

/// Returns the pixel dimensions of a platform image.
public nonisolated func pixelSize(of image: PlatformImage) -> CGSize {
    imagePixelSize(image)
}

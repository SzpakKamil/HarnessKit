import Foundation
import CoreGraphics
import HarnessKitScreenshots

nonisolated func applyShadows(
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

        // Project each `.shape` shadow into a `(ShadowGroupShape, blurPx)`
        // tuple, then bucket by blur radius. Shapes with identical blur
        // share a bbox-sized bitmap; differing blurs need separate
        // CIGaussianBlur passes.
        struct ShapeWithBlur {
            let shape: ShadowGroupShape
            let blurPx: CGFloat
        }
        let shapesWithBlur: [ShapeWithBlur] = shadows.compactMap { shadow in
            guard case .shape(let s) = shadow else { return nil }
            let shadowWidth = CGFloat(s.width) * compositionSize.width
            let shadowHeight = CGFloat(s.height) * compositionSize.height
            let shadowX = compositionCenter.x + CGFloat(s.x) * compositionSize.width / 2 - shadowWidth / 2
            let shadowY = compositionCenter.y + CGFloat(s.y) * compositionSize.height / 2 - shadowHeight / 2
            return ShapeWithBlur(
                shape: ShadowGroupShape(
                    rect: CGRect(x: shadowX, y: shadowY, width: shadowWidth, height: shadowHeight),
                    cornerRadius: CGFloat(s.cornerRadius) * min(shadowWidth, shadowHeight) / 2,
                    color: platformColor(hex: s.color, opacity: s.opacity).cgColor
                ),
                blurPx: CGFloat(s.blur) * refDim
            )
        }

        let buckets = Dictionary(grouping: shapesWithBlur) { Int($0.blurPx * 100) }
        let groups: [(shapes: [ShadowGroupShape], blurPx: CGFloat)] = buckets.values.map {
            (shapes: $0.map(\.shape), blurPx: $0[0].blurPx)
        }

        // Bezel-path uses round-rect (matches the screenshot rounded-corner
        // behavior the rest of the bezel pipeline uses); the canvas-path
        // caller passes `continuousRoundedRectPath` for SwiftUI's continuous
        // corners.
        let renders = renderShadowGroups(groups, canvasRect: canvasRect) { rect, cornerRadius in
            CGPath(
                roundedRect: rect,
                cornerWidth: cornerRadius,
                cornerHeight: cornerRadius,
                transform: nil
            )
        }

        return createImage(size: canvasSize) { ctx in
            for r in renders {
                let bboxImage = platformImage(from: r.image, size: r.bbox.size)
                drawImageInContext(bboxImage, in: r.bbox, context: ctx)
            }

            // Drop shadows are a separate algorithm — applied as the
            // CGContext's shadow attribute on the subsequent screenshot
            // draw rather than rasterized + blurred manually.
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

import Foundation
import CoreGraphics
import HarnessKitScreenshots

// MARK: - Contact Shadow Rendering

func renderContactShadows(onto canvas: PlatformImage, shadows: [CanvasLayerShadow], layerFrame: CGRect) -> PlatformImage {
    let canvasSize = imageSize(canvas)
    let canvasRect = CGRect(origin: .zero, size: canvasSize)
    let refDim = min(layerFrame.width, layerFrame.height)

    // Project each contact shadow into a `ShadowGroupShape` carrying its
    // blur radius, then bucket shapes that share a blur.
    struct ShapeWithBlur {
        let shape: ShadowGroupShape
        let blurPx: CGFloat
    }
    let shapesWithBlur: [ShapeWithBlur] = shadows.map { shadow in
        let sw = CGFloat(shadow.contactWidth) * layerFrame.width
        let sh = CGFloat(shadow.contactHeight) * layerFrame.height
        let sx = layerFrame.midX - sw / 2
        let sy = layerFrame.midY + CGFloat(shadow.contactY) * layerFrame.height / 2 - sh / 2
        return ShapeWithBlur(
            shape: ShadowGroupShape(
                rect: CGRect(x: sx, y: sy, width: sw, height: sh),
                cornerRadius: CGFloat(shadow.contactCornerRadius) * min(sw, sh) / 2,
                color: platformColor(hex: shadow.color, opacity: shadow.opacity).cgColor
            ),
            blurPx: CGFloat(shadow.blur) * refDim
        )
    }

    let buckets = Dictionary(grouping: shapesWithBlur) { Int($0.blurPx * 100) }
    let groups: [(shapes: [ShadowGroupShape], blurPx: CGFloat)] = buckets.values.map {
        (shapes: $0.map(\.shape), blurPx: $0[0].blurPx)
    }

    // Canvas-path uses SwiftUI continuous corners so shadow rectangles
    // match the corner style the interactive editor renders for layers.
    let renders = renderShadowGroups(groups, canvasRect: canvasRect) { rect, cornerRadius in
        continuousRoundedRectPath(rect: rect, radius: cornerRadius)
    }

    guard !renders.isEmpty else { return canvas }
    return createImage(size: canvasSize) { ctx in
        drawImageInContext(canvas, in: canvasRect, context: ctx)
        for r in renders {
            let bboxImage = platformImage(from: r.image, size: r.bbox.size)
            drawImageInContext(bboxImage, in: r.bbox, context: ctx)
        }
    }
}

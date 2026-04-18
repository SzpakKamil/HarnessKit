import Foundation
import CoreGraphics
import HarnessKitScreenshots

nonisolated func adjustResolution(image: PlatformImage, resolution: ScreenshotResolution) -> PlatformImage {
    let canvasSize = resolution.size
    let sourceSize = imageSize(image)
    guard sourceSize.width > 0, sourceSize.height > 0,
          canvasSize.width > 0, canvasSize.height > 0 else { return image }

    // Sub-pixel deltas left by earlier aspect-fit stages shouldn't cost a
    // full-canvas bitmap. Up to ~1 pixel slack collapses to the input.
    if abs(sourceSize.width - canvasSize.width) < 1.5,
       abs(sourceSize.height - canvasSize.height) < 1.5 {
        return image
    }

    let scaleFactor = min(canvasSize.width / sourceSize.width, canvasSize.height / sourceSize.height)
    let drawSize = CGSize(width: sourceSize.width * scaleFactor, height: sourceSize.height * scaleFactor)
    let origin = CGPoint(x: (canvasSize.width - drawSize.width) / 2.0, y: (canvasSize.height - drawSize.height) / 2.0)

    return createImage(size: canvasSize) { ctx in
        ctx.interpolationQuality = .high
        ctx.setFillColor(CGColor(red: 0, green: 0, blue: 0, alpha: 0))
        ctx.fill(CGRect(origin: .zero, size: canvasSize))
        drawImageInContext(image, in: CGRect(origin: origin, size: drawSize), context: ctx)
    }
}

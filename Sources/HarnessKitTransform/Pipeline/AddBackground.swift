import Foundation
import CoreGraphics
import HarnessKitScreenshots

/// Applies a background behind the given image based on the `ScreenshotBackground` type.
public nonisolated func addBackground(
    image: PlatformImage,
    background: ScreenshotBackground?,
    backgroundImageCache: PlatformImage? = nil
) -> PlatformImage {
    guard let background else { return image }

    let size = imageSize(image)
    let rect = CGRect(origin: .zero, size: size)

    return createImage(size: size) { ctx in
        switch background {
        case .solid(let hex):
            ctx.setFillColor(platformColor(hex: hex, opacity: 1.0).cgColor)
            ctx.fill(rect)

        case .gradient(let startHex, let endHex, let angle):
            drawLinearGradient(in: ctx, rect: rect,
                               startColor: platformColor(hex: startHex, opacity: 1.0),
                               endColor: platformColor(hex: endHex, opacity: 1.0),
                               angle: CGFloat(angle))

        case .image(let name, let directory, let scale, let offsetX, let offsetY):
            let bgImg: PlatformImage?
            if let cached = backgroundImageCache {
                bgImg = cached
            } else if let dir = directory {
                // ImageIO-downsample to the canvas's long edge × 2 (Retina
                // safety). A 4K background image behind a 4K canvas still
                // decodes full-res; a user-supplied 12MP photo behind a
                // 2K canvas gets downsampled on load.
                let longEdge = max(rect.width, rect.height)
                let maxPixelSize = longEdge > 0 ? Int(ceil(longEdge * 2)) : nil
                bgImg = platformImage(contentsOfFile: URL(fileURLWithPath: dir).appendingPathComponent(name).path, maxPixelSize: maxPixelSize)
            } else {
                bgImg = nil
            }
            if let bgImg {
                drawBackgroundImage(image: bgImg, in: rect, scale: scale, offsetX: offsetX, offsetY: offsetY, context: ctx)
            }
        }

        drawImageInContext(image, in: rect, context: ctx)
    }
}

private func drawBackgroundImage(image: PlatformImage, in rect: CGRect, scale: Double, offsetX: Double, offsetY: Double, context ctx: CGContext) {
    let srcSize = imageSize(image)
    guard srcSize.width > 0, srcSize.height > 0 else { return }

    let scaleX = rect.width / srcSize.width
    let scaleY = rect.height / srcSize.height
    let baseScale = max(scaleX, scaleY) * CGFloat(scale)

    let drawW = srcSize.width * baseScale
    let drawH = srcSize.height * baseScale
    let drawX = rect.origin.x + (rect.width - drawW) / 2 + CGFloat(offsetX) * rect.width
    let drawY = rect.origin.y + (rect.height - drawH) / 2 + CGFloat(offsetY) * rect.height

    drawImageInContext(image, in: CGRect(x: drawX, y: drawY, width: drawW, height: drawH), context: ctx)
}

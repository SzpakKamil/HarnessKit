import Foundation
import HarnessKitScreenshots

public nonisolated func cropImage(image: PlatformImage, crop: CropRect) -> PlatformImage {
    // No zoom → pan contributes 0 (panX/Y multiply by `(imgSize - sourceSize)/2` which
    // is zero when sourceSize == imgSize). The output is the input regardless of x/y.
    if crop.width == 1.0, crop.height == 1.0 {
        return image
    }

    let imgSize = imageSize(image)
    let viewportSize = imgSize

    let zoomX = CGFloat(crop.width)
    let zoomY = CGFloat(crop.height)

    let sourceWidth = viewportSize.width / zoomX
    let sourceHeight = viewportSize.height / zoomY

    let centerX = imgSize.width / 2
    let centerY = imgSize.height / 2

    let panX = (imgSize.width - sourceWidth) / 2 * CGFloat(crop.x)
    let panY = (imgSize.height - sourceHeight) / 2 * CGFloat(crop.y)

    let sourceRect = CGRect(
        x: centerX - sourceWidth / 2 + panX,
        y: centerY - sourceHeight / 2 + panY,
        width: sourceWidth,
        height: sourceHeight
    )

    guard let cgImg = cgImage(from: image) else { return image }

    let cropRect = CGRect(
        x: sourceRect.origin.x,
        y: imgSize.height - sourceRect.origin.y - sourceRect.height,
        width: sourceRect.width,
        height: sourceRect.height
    )

    guard let cropped = cgImg.cropping(to: cropRect) else { return image }

    // Fast path: the cropped subimage already matches the viewport.
    // `CGImage.cropping(to:)` shares the source buffer, so wrapping it
    // directly skips the full-canvas bitmap a redraw would allocate.
    // Hit when near-1.0 zoom factors clamp to full-image bounds, or when
    // a caller explicitly zooms out beyond the image (we treat it as identity).
    if cropped.width == Int(viewportSize.width), cropped.height == Int(viewportSize.height) {
        return platformImage(from: cropped, size: viewportSize)
    }

    let destinationRect = CGRect(origin: .zero, size: viewportSize)
    return createImage(size: viewportSize) { ctx in
        ctx.interpolationQuality = .high
        ctx.draw(cropped, in: destinationRect)
    }
}

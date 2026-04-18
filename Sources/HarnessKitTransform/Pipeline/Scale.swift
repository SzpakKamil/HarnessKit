import Foundation

nonisolated func scaleToBezel(image: PlatformImage, factor: CGFloat) -> PlatformImage {
    guard factor != 1.0 else { return image }

    let originalSize = imageSize(image)
    let scaledSize = CGSize(
        width: originalSize.width * factor,
        height: originalSize.height * factor
    )

    return createImage(size: scaledSize) { ctx in
        drawImageInContext(image, in: CGRect(origin: .zero, size: scaledSize), context: ctx)
    }
}

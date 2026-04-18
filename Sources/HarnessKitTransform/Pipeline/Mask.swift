import Foundation

/// Clips an image to a rounded rectangle using the given corner radius.
/// Pass `0` to skip clipping and return the original image unchanged.
public nonisolated func maskScreenshot(image: PlatformImage, cornerRadius: CGFloat) -> PlatformImage {
    guard cornerRadius > 0 else { return image }

    let size = imageSize(image)
    return createImage(size: size) { ctx in
        let rect = CGRect(origin: .zero, size: size)
        let path = makeRoundedRectPath(rect: rect, xRadius: cornerRadius, yRadius: cornerRadius)
        #if canImport(AppKit)
        path.addClip()
        drawImageInContext(image, in: rect, context: ctx)
        #else
        ctx.addPath(path.cgPath)
        ctx.clip()
        drawImageInContext(image, in: rect, context: ctx)
        #endif
    }
}

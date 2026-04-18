import Foundation

public nonisolated func placeBezel(
    image: PlatformImage,
    bezel: PlatformImage,
    verticalOffset: CGFloat,
    horizontalOffset: CGFloat = 0,
    screenshotOnTop: Bool = false,
    scaleUpToFill: Bool = true,
    nativeScreenSize: CGSize? = nil
) -> PlatformImage {

    let bezelPixels = imagePixelSize(bezel)
    let imagePixels = imagePixelSize(image)

    guard imagePixels.width > 0, imagePixels.height > 0,
          bezelPixels.width > 0, bezelPixels.height > 0 else { return image }

    let imageAspect = imagePixels.width / imagePixels.height
    let canvasAspect = bezelPixels.width / bezelPixels.height

    var fittedSize: CGSize
    if imageAspect > canvasAspect {
        fittedSize = CGSize(width: bezelPixels.width, height: bezelPixels.width / imageAspect)
    } else {
        fittedSize = CGSize(width: bezelPixels.height * imageAspect, height: bezelPixels.height)
    }

    if !scaleUpToFill {
        if let native = nativeScreenSize, native.width > 0, native.height > 0 {
            let nativeAspect = native.width / native.height
            let nativeFit: CGSize
            if nativeAspect > canvasAspect {
                nativeFit = CGSize(width: bezelPixels.width, height: bezelPixels.width / nativeAspect)
            } else {
                nativeFit = CGSize(width: bezelPixels.height * nativeAspect, height: bezelPixels.height)
            }
            let ratio = min(imagePixels.width / native.width, imagePixels.height / native.height, 1.0)
            fittedSize = CGSize(width: nativeFit.width * ratio, height: nativeFit.height * ratio)
        } else {
            fittedSize = CGSize(width: fittedSize.width * 0.5, height: fittedSize.height * 0.5)
        }
    }

    let verticalPx = verticalOffset * bezelPixels.height
    let horizontalPx = horizontalOffset * bezelPixels.width

    let origin = CGPoint(
        x: (bezelPixels.width - fittedSize.width) / 2.0 + horizontalPx,
        y: (bezelPixels.height - fittedSize.height) / 2.0 + verticalPx
    )

    let finalFittedSize = fittedSize
    return createImage(size: bezelPixels) { ctx in
        let imgRect = CGRect(origin: origin, size: finalFittedSize)
        let bezelRect = CGRect(origin: .zero, size: bezelPixels)

        if !screenshotOnTop {
            drawImageInContext(image, in: imgRect, context: ctx)
            drawImageInContext(bezel, in: bezelRect, context: ctx)
        } else {
            drawImageInContext(bezel, in: bezelRect, context: ctx)
            drawImageInContext(image, in: imgRect, context: ctx)
        }
    }
}

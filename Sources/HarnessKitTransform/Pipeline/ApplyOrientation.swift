import Foundation
import HarnessKitScreenshots

nonisolated func applyOrientation(image: PlatformImage, orientation: ScreenOrientation) -> PlatformImage {
    guard orientation == .landscape else { return image }

    let imgSize = imageSize(image)
    let rotatedSize = CGSize(width: imgSize.height, height: imgSize.width)

    return createImage(size: rotatedSize) { ctx in
        ctx.translateBy(x: rotatedSize.width / 2, y: rotatedSize.height / 2)
        ctx.rotate(by: .pi / 2)
        if let cg = cgImage(from: image) {
            ctx.draw(cg, in: CGRect(x: -imgSize.width / 2, y: -imgSize.height / 2,
                                    width: imgSize.width, height: imgSize.height))
        }
    }
}

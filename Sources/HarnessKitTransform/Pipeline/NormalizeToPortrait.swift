import Foundation
import HarnessKitScreenshots

nonisolated func normalizeToPortrait(image: PlatformImage, os: TargetOS) -> PlatformImage {
    if os.isMacOS { return image }

    // One-shot orientation bake. `drawImageInContext` on UIKit
    // platforms now assumes `.up`, so every non-macOS image entering
    // the pipeline is normalized here and nowhere else. No-op on
    // macOS (NSImage carries no orientation flag).
    let oriented = normalizeOrientation(image)

    if os == .iOS || os == .iPadOS {
        let imgSize = imageSize(oriented)
        guard imgSize.width > imgSize.height else { return oriented }

        let rotatedSize = CGSize(width: imgSize.height, height: imgSize.width)
        return createImage(size: rotatedSize) { ctx in
            ctx.translateBy(x: rotatedSize.width / 2, y: rotatedSize.height / 2)
            ctx.rotate(by: -.pi / 2)
            if let cg = cgImage(from: oriented) {
                ctx.draw(cg, in: CGRect(x: -imgSize.width / 2, y: -imgSize.height / 2,
                                        width: imgSize.width, height: imgSize.height))
            }
        }
    }

    return oriented
}

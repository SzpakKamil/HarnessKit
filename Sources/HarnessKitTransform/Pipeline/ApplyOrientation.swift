//
//  ApplyOrientation.swift
//  HarnessKitTransform
//

import Foundation
import AppKit
import HarnessKitScreenshots

public nonisolated func applyOrientation(image: NSImage, orientation: ScreenOrientation) -> NSImage {
    guard orientation == .landscape else {
        return image
    }

    let imageSize = image.size
    let rotatedSize = CGSize(
        width: imageSize.height,
        height: imageSize.width
    )

    return NSImage(size: rotatedSize, flipped: false) { _ in
        guard let context = NSGraphicsContext.current?.cgContext else { return false }

        context.translateBy(x: rotatedSize.width / 2, y: rotatedSize.height / 2)
        context.rotate(by: .pi / 2)

        let drawRect = CGRect(
            x: -imageSize.width / 2,
            y: -imageSize.height / 2,
            width: imageSize.width,
            height: imageSize.height
        )

        if let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) {
            context.draw(cgImage, in: drawRect)
        }
        return true
    }
}

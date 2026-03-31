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

    let originalSize = image.size
    let rotatedSize = CGSize(
        width: originalSize.height,
        height: originalSize.width
    )

    let rotatedImage = NSImage(size: rotatedSize)
    rotatedImage.lockFocus()

    guard let context = NSGraphicsContext.current?.cgContext else {
        rotatedImage.unlockFocus()
        return image
    }

    context.translateBy(x: rotatedSize.width / 2, y: rotatedSize.height / 2)
    context.rotate(by: .pi / 2)

    let drawRect = CGRect(
        x: -originalSize.width / 2,
        y: -originalSize.height / 2,
        width: originalSize.width,
        height: originalSize.height
    )

    if let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) {
        context.draw(cgImage, in: drawRect)
    }

    rotatedImage.unlockFocus()
    return rotatedImage
}

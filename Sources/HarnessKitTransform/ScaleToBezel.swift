//
//  ScaleToBezel.swift
//  HarnessKitTransform
//

import Foundation
import AppKit

public nonisolated func scaleToBezel(image: NSImage, factor: CGFloat) -> NSImage {
    let originalSize = image.size
    let scaledSize = NSSize(
        width: originalSize.width * factor,
        height: originalSize.height * factor
    )

    let origin = NSPoint(
        x: (originalSize.width - scaledSize.width) / 2.0,
        y: (originalSize.height - scaledSize.height) / 2.0
    )

    let newImage = NSImage(size: originalSize)
    newImage.lockFocus()
    image.draw(
        in: NSRect(origin: origin, size: scaledSize),
        from: NSRect(origin: .zero, size: originalSize),
        operation: .copy,
        fraction: 1.0
    )
    newImage.unlockFocus()

    return newImage
}

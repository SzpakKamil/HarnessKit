//
//  ScaleToBezel.swift
//  HarnessKitTransform
//

import Foundation
import AppKit

public nonisolated func scaleToBezel(image: NSImage, factor: CGFloat) -> NSImage {
    guard factor != 1.0 else { return image }

    let originalSize = image.size
    let scaledSize = NSSize(
        width: originalSize.width * factor,
        height: originalSize.height * factor
    )

    let origin = NSPoint(
        x: (originalSize.width - scaledSize.width) / 2.0,
        y: (originalSize.height - scaledSize.height) / 2.0
    )

    return NSImage(size: originalSize, flipped: false) { _ in
        image.draw(
            in: NSRect(origin: origin, size: scaledSize),
            from: NSRect(origin: .zero, size: originalSize),
            operation: .copy,
            fraction: 1.0
        )
        return true
    }
}

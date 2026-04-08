//
//  MaskScreenshot.swift
//  HarnessKitTransform
//

import Foundation
import AppKit

/// Clips an image to a rounded rectangle using the given corner radius.
/// Pass `0` to skip clipping and return the original image unchanged.
public nonisolated func maskScreenshot(image: NSImage, cornerRadius: CGFloat) -> NSImage {
    guard cornerRadius > 0 else { return image }

    let imageSize = image.size
    return NSImage(size: imageSize, flipped: false) { _ in
        let path = NSBezierPath(
            roundedRect: NSRect(origin: .zero, size: imageSize),
            xRadius: cornerRadius,
            yRadius: cornerRadius
        )
        path.addClip()

        image.draw(
            in: NSRect(origin: .zero, size: imageSize),
            from: NSRect(origin: .zero, size: imageSize),
            operation: .sourceOver,
            fraction: 1.0
        )
        return true
    }
}

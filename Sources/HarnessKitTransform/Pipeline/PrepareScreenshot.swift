//
//  PrepareScreenshot.swift
//  HarnessKitTransform
//

import Foundation
import AppKit
import HarnessKitScreenshots

public nonisolated func prepareScreenshot(image: NSImage, os: TargetOS) -> NSImage {
    // macOS: return unchanged — bezel handles positioning, shadows use ScreenshotShadow entries
    if os.isMacOS {
        return image
    }

    // iOS/iPadOS: rotate landscape captures back to portrait for processing
    if os == .iOS || os == .iPadOS {
        let imageSize = image.size
        guard imageSize.width > imageSize.height else {
            return image
        }

        let rotatedSize = NSSize(width: imageSize.height, height: imageSize.width)
        return NSImage(size: rotatedSize, flipped: false) { _ in
            let transform = NSAffineTransform()
            transform.translateX(by: rotatedSize.width / 2, yBy: rotatedSize.height / 2)
            transform.rotate(byDegrees: -90)
            transform.translateX(by: -imageSize.width / 2, yBy: -imageSize.height / 2)
            transform.concat()

            image.draw(at: .zero, from: NSRect(origin: .zero, size: imageSize), operation: .sourceOver, fraction: 1.0)
            return true
        }
    }

    return image
}

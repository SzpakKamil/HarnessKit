//
//  PrepareScreenshot.swift
//  HarnessKitTransform
//

import Foundation
import AppKit
import HarnessKitScreenshots

public nonisolated func prepareScreenshot(image: NSImage, scaleMacOS: Bool = true, os: TargetOS) -> NSImage {
    if os.isMacOS {
        let baseContainerSize = CGSize(width: 3456, height: 2168)

        let targetSize: CGSize
        if scaleMacOS {
            let widthRatio = baseContainerSize.width / image.size.width
            let heightRatio = baseContainerSize.height / image.size.height
            let scale = min(widthRatio, heightRatio)
            targetSize = CGSize(width: image.size.width * scale, height: image.size.height * scale)
        } else {
            targetSize = image.size
        }

        let shadowBlur: CGFloat = 50
        let shadowOffset = CGSize(width: 0, height: -6)
        let shadowOpacity: CGFloat = 0.15

        let shouldApplyShadow = targetSize.width < (baseContainerSize.width * 0.9)

        let extraLeft: CGFloat   = shouldApplyShadow ? (shadowBlur + max(0, -shadowOffset.width)) : 0
        let extraRight: CGFloat  = shouldApplyShadow ? (shadowBlur + max(0, shadowOffset.width)) : 0
        let extraTop: CGFloat    = shouldApplyShadow ? (shadowBlur + max(0, shadowOffset.height)) : 0
        let extraBottom: CGFloat = shouldApplyShadow ? (shadowBlur + max(0, -shadowOffset.height)) : 0

        let canvasSize = CGSize(
            width: baseContainerSize.width + extraLeft + extraRight,
            height: baseContainerSize.height + extraTop + extraBottom
        )

        let result = NSImage(size: canvasSize)
        result.lockFocus()

        let baseOrigin = CGPoint(
            x: (baseContainerSize.width - targetSize.width) / 2,
            y: (baseContainerSize.height - targetSize.height) / 2
        )
        let drawOrigin = CGPoint(
            x: baseOrigin.x + extraLeft,
            y: baseOrigin.y + extraTop
        )

        if shouldApplyShadow {
            NSGraphicsContext.saveGraphicsState()
            let shadow = NSShadow()
            shadow.shadowBlurRadius = shadowBlur
            shadow.shadowOffset = shadowOffset
            shadow.shadowColor = NSColor.black.withAlphaComponent(shadowOpacity)
            shadow.set()
        }

        image.draw(
            in: NSRect(origin: drawOrigin, size: targetSize),
            from: NSRect(origin: .zero, size: image.size),
            operation: .sourceOver,
            fraction: 1.0
        )

        if shouldApplyShadow {
            NSGraphicsContext.restoreGraphicsState()
        }

        result.unlockFocus()
        return result
    }

    if os == .iOS || os == .iPadOS {
        guard image.size.width > image.size.height else {
            return image
        }

        let rotatedSize = CGSize(width: image.size.height, height: image.size.width)
        let rotatedImage = NSImage(size: rotatedSize)

        rotatedImage.lockFocus()
        let transform = NSAffineTransform()
        transform.translateX(by: rotatedSize.width / 2, yBy: rotatedSize.height / 2)
        transform.rotate(byDegrees: -90)
        transform.translateX(by: -image.size.width / 2, yBy: -image.size.height / 2)
        transform.concat()

        image.draw(at: .zero, from: NSRect(origin: .zero, size: image.size), operation: .sourceOver, fraction: 1.0)
        rotatedImage.unlockFocus()

        return rotatedImage
    }

    return image
}

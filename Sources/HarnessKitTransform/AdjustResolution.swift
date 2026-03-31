//
//  AdjustResolution.swift
//  HarnessKitTransform
//

import Foundation
import AppKit
import HarnessKitScreenshots

public nonisolated func adjustResolution(image: NSImage, resolution: ScreenshotResolution) -> NSImage {
    let canvasSize = resolution.size

    let sourceSize = image.size
    guard sourceSize.width > 0, sourceSize.height > 0,
          canvasSize.width > 0, canvasSize.height > 0 else { return image }

    let widthRatio = canvasSize.width / sourceSize.width
    let heightRatio = canvasSize.height / sourceSize.height
    let scaleFactor = min(widthRatio, heightRatio)

    let drawSize = CGSize(
        width: sourceSize.width * scaleFactor,
        height: sourceSize.height * scaleFactor
    )

    let origin = CGPoint(
        x: (canvasSize.width - drawSize.width) / 2.0,
        y: (canvasSize.height - drawSize.height) / 2.0
    )

    let newImage = NSImage(size: canvasSize)
    newImage.lockFocus()

    if let context = NSGraphicsContext.current {
        context.imageInterpolation = .high
    }

    NSColor.clear.set()
    NSRect(origin: .zero, size: canvasSize).fill()

    image.draw(
        in: NSRect(origin: origin, size: drawSize),
        from: NSRect(origin: .zero, size: sourceSize),
        operation: .sourceOver,
        fraction: 1.0,
        respectFlipped: false,
        hints: [.interpolation: NSImageInterpolation.low]
    )

    newImage.unlockFocus()
    return newImage
}

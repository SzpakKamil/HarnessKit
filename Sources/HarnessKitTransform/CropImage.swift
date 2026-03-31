//
//  CropImage.swift
//  HarnessKitTransform
//

import Foundation
import AppKit
import HarnessKitScreenshots

public nonisolated func cropImage(image: NSImage, crop: CropRect) -> NSImage {
    let imageSize = image.size
    let viewportSize = imageSize

    let zoomX = CGFloat(crop.width)
    let zoomY = CGFloat(crop.height)

    let sourceWidth = viewportSize.width / zoomX
    let sourceHeight = viewportSize.height / zoomY

    let centerX = imageSize.width / 2
    let centerY = imageSize.height / 2

    let panX = (imageSize.width - sourceWidth) / 2 * CGFloat(crop.x)
    let panY = (imageSize.height - sourceHeight) / 2 * CGFloat(crop.y)

    let sourceRect = NSRect(
        x: centerX - sourceWidth / 2 + panX,
        y: centerY - sourceHeight / 2 + panY,
        width: sourceWidth,
        height: sourceHeight
    )

    let finalImage = NSImage(size: viewportSize)
    finalImage.lockFocus()

    let destinationRect = NSRect(origin: .zero, size: viewportSize)

    image.draw(
        in: destinationRect,
        from: sourceRect,
        operation: .copy,
        fraction: 1.0,
        respectFlipped: false,
        hints: [.interpolation: NSImageInterpolation.high]
    )

    finalImage.unlockFocus()
    return finalImage
}

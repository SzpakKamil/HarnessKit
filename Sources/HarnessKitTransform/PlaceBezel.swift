//
//  PlaceBezel.swift
//  HarnessKitTransform
//

import Foundation
import AppKit

public nonisolated func placeBezel(
    image: NSImage,
    bezel: NSImage,
    verticalOffset: CGFloat,
    screenshotOnTop: Bool = false
) -> NSImage {

    let canvasSize = bezel.size

    let imageAspect = image.size.width / image.size.height
    let canvasAspect = canvasSize.width / canvasSize.height

    let fittedSize: NSSize
    if imageAspect > canvasAspect {
        fittedSize = NSSize(
            width: canvasSize.width,
            height: canvasSize.width / imageAspect
        )
    } else {
        fittedSize = NSSize(
            width: canvasSize.height * imageAspect,
            height: canvasSize.height
        )
    }

    let origin = NSPoint(
        x: (canvasSize.width - fittedSize.width) / 2.0,
        y: (canvasSize.height - fittedSize.height) / 2.0 + verticalOffset
    )

    let result = NSImage(size: canvasSize)
    result.lockFocus()

    if !screenshotOnTop {
        image.draw(
            in: NSRect(origin: origin, size: fittedSize),
            from: NSRect(origin: .zero, size: image.size),
            operation: .sourceOver,
            fraction: 1.0
        )
        bezel.draw(
            in: NSRect(origin: .zero, size: canvasSize),
            from: NSRect(origin: .zero, size: bezel.size),
            operation: .sourceOver,
            fraction: 1.0
        )
    } else {
        bezel.draw(
            in: NSRect(origin: .zero, size: canvasSize),
            from: NSRect(origin: .zero, size: bezel.size),
            operation: .sourceOver,
            fraction: 1.0
        )
        image.draw(
            in: NSRect(origin: origin, size: fittedSize),
            from: NSRect(origin: .zero, size: image.size),
            operation: .sourceOver,
            fraction: 1.0
        )
    }

    result.unlockFocus()
    return result
}

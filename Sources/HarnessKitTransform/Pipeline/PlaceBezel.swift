//
//  PlaceBezel.swift
//  HarnessKitTransform
//

import Foundation
import AppKit

/// Places the screenshot inside the bezel frame.
/// Layout uses pixel dimensions (via `pixelSize(of:)`) for DPI-independent sizing.
/// Drawing uses `image.size` for source rects (AppKit's coordinate system).
///
/// - Parameters:
///   - verticalOffset: Fraction of bezel height to shift the screenshot vertically.
///   - horizontalOffset: Fraction of bezel width to shift the screenshot horizontally.
///   - scaleUpToFill: When true (default), the screenshot is always scaled to fill the bezel.
///     When false with `nativeScreenSize`, the screenshot is placed at natural pixel density
///     (centered if smaller than native, scaled to fit if larger). When false without
///     `nativeScreenSize`, falls back to 50% of aspect-fit for placeholder display.
///   - nativeScreenSize: Native screen resolution in pixels. Used when `scaleUpToFill == false`
///     to compute the screenshot's natural display size relative to the device screen.
public nonisolated func placeBezel(
    image: NSImage,
    bezel: NSImage,
    verticalOffset: CGFloat,
    horizontalOffset: CGFloat = 0,
    screenshotOnTop: Bool = false,
    scaleUpToFill: Bool = true,
    nativeScreenSize: NSSize? = nil
) -> NSImage {

    // Use pixel dimensions for layout math to avoid DPI inconsistencies
    let bezelPixels = pixelSize(of: bezel)
    let imagePixels = pixelSize(of: image)

    guard imagePixels.width > 0, imagePixels.height > 0,
          bezelPixels.width > 0, bezelPixels.height > 0 else { return image }

    let imageAspect = imagePixels.width / imagePixels.height
    let canvasAspect = bezelPixels.width / bezelPixels.height

    var fittedSize: NSSize
    if imageAspect > canvasAspect {
        fittedSize = NSSize(
            width: bezelPixels.width,
            height: bezelPixels.width / imageAspect
        )
    } else {
        fittedSize = NSSize(
            width: bezelPixels.height * imageAspect,
            height: bezelPixels.height
        )
    }

    if !scaleUpToFill {
        if let native = nativeScreenSize, native.width > 0, native.height > 0 {
            // Compute how native screen fills the bezel canvas (aspect-fit)
            let nativeAspect = native.width / native.height
            let nativeFit: NSSize
            if nativeAspect > canvasAspect {
                nativeFit = NSSize(width: bezelPixels.width, height: bezelPixels.width / nativeAspect)
            } else {
                nativeFit = NSSize(width: bezelPixels.height * nativeAspect, height: bezelPixels.height)
            }
            // ratio: fraction of native screen this screenshot covers, clamped to 1 (no upscaling)
            let ratio = min(imagePixels.width / native.width, imagePixels.height / native.height, 1.0)
            fittedSize = NSSize(width: nativeFit.width * ratio, height: nativeFit.height * ratio)
        } else {
            // Placeholder fallback: scale down to show screen area within bezel
            let placeholderScale: CGFloat = 0.5
            fittedSize = NSSize(width: fittedSize.width * placeholderScale, height: fittedSize.height * placeholderScale)
        }
    }

    let verticalPx = verticalOffset * bezelPixels.height
    let horizontalPx = horizontalOffset * bezelPixels.width

    let origin = NSPoint(
        x: (bezelPixels.width - fittedSize.width) / 2.0 + horizontalPx,
        y: (bezelPixels.height - fittedSize.height) / 2.0 + verticalPx
    )

    // Canvas at pixel dimensions — .size will equal pixel dims (72 DPI)
    return NSImage(size: bezelPixels, flipped: false) { _ in
        if !screenshotOnTop {
            image.draw(
                in: NSRect(origin: origin, size: fittedSize),
                from: NSRect(origin: .zero, size: image.size),
                operation: .sourceOver,
                fraction: 1.0
            )
            bezel.draw(
                in: NSRect(origin: .zero, size: bezelPixels),
                from: NSRect(origin: .zero, size: bezel.size),
                operation: .sourceOver,
                fraction: 1.0
            )
        } else {
            bezel.draw(
                in: NSRect(origin: .zero, size: bezelPixels),
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
        return true
    }
}

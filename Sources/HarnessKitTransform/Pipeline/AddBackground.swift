//
//  AddBackground.swift
//  HarnessKitTransform
//

import Foundation
#if canImport(AppKit)
import AppKit
import HarnessKitScreenshots

/// Applies a background behind the given image based on the `ScreenshotBackground` type.
public nonisolated func addBackground(
    image: NSImage,
    background: ScreenshotBackground?,
    backgroundImageCache: NSImage? = nil
) -> NSImage {
    guard let background else { return image }

    let size = image.size
    return NSImage(size: size, flipped: false) { _ in
        switch background {
        case .solid(let hex):
            colorFromHex(hex).setFill()
            NSRect(origin: .zero, size: size).fill()

        case .gradient(let startHex, let endHex, let angle):
            let startColor = colorFromHex(startHex)
            let endColor = colorFromHex(endHex)
            if let gradient = NSGradient(colors: [startColor, endColor]) {
                gradient.draw(in: NSRect(origin: .zero, size: size), angle: CGFloat(angle))
            }

        case .image(let name, let directory, let scale, let offsetX, let offsetY):
            let bgImg: NSImage?
            if let cached = backgroundImageCache {
                bgImg = cached
            } else if let dir = directory {
                bgImg = NSImage(contentsOf: URL(fileURLWithPath: dir).appendingPathComponent(name))
            } else {
                bgImg = nil
            }
            if let bgImg {
                drawBackgroundImage(image: bgImg, in: NSRect(origin: .zero, size: size), scale: scale, offsetX: offsetX, offsetY: offsetY)
            }
        }

        image.draw(
            in: NSRect(origin: .zero, size: size),
            from: NSRect(origin: .zero, size: size),
            operation: .sourceOver,
            fraction: 1.0
        )
        return true
    }
}

// MARK: - Private Helpers

private func colorFromHex(_ hex: String) -> NSColor {
    let cleaned = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
    var int: UInt64 = 0
    Scanner(string: cleaned).scanHexInt64(&int)
    return NSColor(
        red: CGFloat((int >> 16) & 0xFF) / 255.0,
        green: CGFloat((int >> 8) & 0xFF) / 255.0,
        blue: CGFloat(int & 0xFF) / 255.0,
        alpha: 1.0
    )
}

/// Draws the source image into the destination rect with aspect-fill, scale, and offset control.
private func drawBackgroundImage(image: NSImage, in rect: NSRect, scale: Double, offsetX: Double, offsetY: Double) {
    let srcSize = image.size
    guard srcSize.width > 0, srcSize.height > 0 else { return }

    let scaleX = rect.width / srcSize.width
    let scaleY = rect.height / srcSize.height
    let baseScale = max(scaleX, scaleY) * CGFloat(scale)

    let drawW = srcSize.width * baseScale
    let drawH = srcSize.height * baseScale
    let drawX = rect.origin.x + (rect.width - drawW) / 2 + CGFloat(offsetX) * rect.width
    let drawY = rect.origin.y + (rect.height - drawH) / 2 + CGFloat(offsetY) * rect.height

    image.draw(
        in: NSRect(x: drawX, y: drawY, width: drawW, height: drawH),
        from: NSRect(origin: .zero, size: srcSize),
        operation: .sourceOver,
        fraction: 1.0
    )
}
#endif

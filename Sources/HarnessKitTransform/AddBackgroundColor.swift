//
//  AddBackgroundColor.swift
//  HarnessKitTransform
//

import Foundation
#if canImport(AppKit)
import AppKit

public nonisolated func addBackgroundColor(image: NSImage, color: String?) -> NSImage {
    guard let color else { return image }
    let hex = color.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
    var int: UInt64 = 0
    Scanner(string: hex).scanHexInt64(&int)

    let r = CGFloat((int >> 16) & 0xFF) / 255.0
    let g = CGFloat((int >> 8) & 0xFF) / 255.0
    let b = CGFloat(int & 0xFF) / 255.0

    let backgroundColor = NSColor(red: r, green: g, blue: b, alpha: 1.0)

    let size = image.size
    let result = NSImage(size: size)

    result.lockFocus()
    backgroundColor.setFill()
    NSRect(origin: .zero, size: size).fill()

    image.draw(
        in: NSRect(origin: .zero, size: size),
        from: NSRect(origin: .zero, size: size),
        operation: .sourceOver,
        fraction: 1.0
    )
    result.unlockFocus()

    return result
}
#endif

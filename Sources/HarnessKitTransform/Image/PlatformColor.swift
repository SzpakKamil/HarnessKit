import Foundation
import CoreGraphics

/// Non-alphanumeric characters stripped from hex color strings. Hoisted to
/// module scope so repeated `platformColor(hex:)` calls (dozens per canvas
/// render) don't rebuild the inverted bitmap every time.
private let hexTrimCharacters: CharacterSet = CharacterSet.alphanumerics.inverted

/// Creates a platform color from a hex string and opacity.
nonisolated func platformColor(hex: String, opacity: Double) -> PlatformColor {
    let cleaned = hex.trimmingCharacters(in: hexTrimCharacters)
    var int: UInt64 = 0
    Scanner(string: cleaned).scanHexInt64(&int)
    return PlatformColor(
        red: CGFloat((int >> 16) & 0xFF) / 255.0,
        green: CGFloat((int >> 8) & 0xFF) / 255.0,
        blue: CGFloat(int & 0xFF) / 255.0,
        alpha: CGFloat(opacity)
    )
}

import Foundation
import CoreGraphics
#if canImport(AppKit)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

/// Creates a platform font matching the given parameters.
nonisolated func resolveFont(family: String, size: CGFloat, weight: Int, italic: Bool) -> PlatformFont {
    #if canImport(AppKit)
    let nsWeight: NSFont.Weight = switch weight {
    case ..<150: .ultraLight
    case ..<250: .thin
    case ..<350: .light
    case ..<450: .regular
    case ..<550: .medium
    case ..<650: .semibold
    case ..<750: .bold
    case ..<850: .heavy
    default: .black
    }
    let descriptor = NSFontDescriptor(fontAttributes: [
        .family: family,
        .traits: [NSFontDescriptor.TraitKey.weight: nsWeight]
    ])
    let resolved = italic ? descriptor.withSymbolicTraits(.italic) : descriptor
    return NSFont(descriptor: resolved, size: size)
        ?? NSFont.systemFont(ofSize: size, weight: nsWeight)
    #else
    let uiWeight: UIFont.Weight = switch weight {
    case ..<150: .ultraLight
    case ..<250: .thin
    case ..<350: .light
    case ..<450: .regular
    case ..<550: .medium
    case ..<650: .semibold
    case ..<750: .bold
    case ..<850: .heavy
    default: .black
    }
    var descriptor = UIFontDescriptor(fontAttributes: [
        .family: family,
        .traits: [UIFontDescriptor.TraitKey.weight: uiWeight]
    ])
    if italic {
        descriptor = descriptor.withSymbolicTraits(.traitItalic) ?? descriptor
    }
    return UIFont(descriptor: descriptor, size: size)
    #endif
}

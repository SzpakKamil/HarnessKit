//
//  MacDeviceDescriptor.swift
//  HarnessKitTransform
//

import Foundation
import AppKit
import HarnessKitScreenshots

/// Describes a macOS device model with its available color variants.
/// Loaded from `mac_devices.json` in the module bundle.
///
/// Bezel image filename pattern (Screenshot-style `key*value^key*value`):
///   `device*{family}^size*{size}^models*{M1+M2+...}^color*{color}^os*{osMajor}^wallpaper*{type}^appearance*{appearance}.png`
///
/// Example — a file shared by MacbookPro 14" M1–M5 in Silver, macOS 26, Default wallpaper, Dark mode:
///   `device*MacbookPro^size*14^models*M1+M2+M3+M4+M5^color*Silver^os*26^wallpaper*Default^appearance*Dark.png`
///
/// The `models` field is a `+`-delimited set: a single bezel file covers every generation
/// whose chassis renders visually identical, eliminating duplicates across M1–M5.
public struct MacDeviceDescriptor: Equatable, Hashable, Sendable, Codable {
    /// Unique device model ID (without color), e.g. `"MacbookPro16M4"`.
    public let id: String
    public let model: String
    public let processor: String
    /// Available color variants for this device model, e.g. `["Silver", "SpaceBlack"]`.
    public let colors: [String]
    public let runDestination: String
    public let scale: CGFloat
    public let verticalOffset: CGFloat
    public let horizontalOffset: CGFloat
    /// Keys: OS major version strings (e.g. `"26"`, `"15"`).
    /// Values: wallpaper type tokens available for that OS (e.g. `["Default", "Custom"]`).
    public let supportedOS: [String: [String]]
    public let nativeWidth: Int
    public let nativeHeight: Int

    // MARK: - Codable

    private enum CodingKeys: String, CodingKey {
        case id, model, processor, colors, runDestination, scale,
             verticalOffset, horizontalOffset, supportedOS, nativeWidth, nativeHeight
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id               = try c.decode(String.self,               forKey: .id)
        model            = try c.decode(String.self,               forKey: .model)
        processor        = try c.decode(String.self,               forKey: .processor)
        colors           = try c.decode([String].self,             forKey: .colors)
        runDestination   = try c.decode(String.self,               forKey: .runDestination)
        scale            = try c.decode(CGFloat.self,              forKey: .scale)
        verticalOffset   = try c.decode(CGFloat.self,              forKey: .verticalOffset)
        horizontalOffset = (try? c.decode(CGFloat.self,            forKey: .horizontalOffset)) ?? 0
        supportedOS      = try c.decode([String: [String]].self,   forKey: .supportedOS)
        nativeWidth      = (try? c.decode(Int.self,                forKey: .nativeWidth)) ?? 0
        nativeHeight     = (try? c.decode(Int.self,                forKey: .nativeHeight)) ?? 0
    }

    public func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id,                 forKey: .id)
        try c.encode(model,              forKey: .model)
        try c.encode(processor,          forKey: .processor)
        try c.encode(colors,             forKey: .colors)
        try c.encode(runDestination,     forKey: .runDestination)
        try c.encode(scale,              forKey: .scale)
        try c.encode(verticalOffset,     forKey: .verticalOffset)
        try c.encode(horizontalOffset,   forKey: .horizontalOffset)
        try c.encode(supportedOS,        forKey: .supportedOS)
        if nativeWidth > 0 { try c.encode(nativeWidth, forKey: .nativeWidth) }
        if nativeHeight > 0 { try c.encode(nativeHeight, forKey: .nativeHeight) }
    }

    // MARK: - Bezel image

    /// Splits the device `id` into `(family, size, model)`.
    ///
    /// Handles two formats:
    /// - M-series: `"MacbookPro14M4"` → `("MacbookPro", "14", "M4")`
    /// - A-series: `"MacbookNeo13A18Pro"` → `("MacbookNeo", "13", "A18Pro")`
    private var parsedID: (device: String, size: String, model: String)? {
        // M-series: ends with digits then M+digits  e.g. MacbookPro14M4
        if let match = id.range(of: #"\d+M\d+$"#, options: .regularExpression) {
            let suffix = id[match]
            let family = String(id[id.startIndex..<match.lowerBound])
            let digits = suffix.prefix { $0.isNumber }
            let model = suffix.dropFirst(digits.count)
            return (family, String(digits), String(model))
        }
        // A-series: ends with A+digits+optional letters  e.g. MacbookNeo13A18Pro
        if let modelMatch = id.range(of: #"A\d+[A-Za-z]*$"#, options: .regularExpression) {
            let model = String(id[modelMatch])
            let beforeModel = String(id[id.startIndex..<modelMatch.lowerBound])
            // Extract trailing size digits from the part before the model token
            if let sizeMatch = beforeModel.range(of: #"\d+$"#, options: .regularExpression) {
                let size = String(beforeModel[sizeMatch])
                let family = String(beforeModel[beforeModel.startIndex..<sizeMatch.lowerBound])
                return (family, size, model)
            }
            return (beforeModel, "", model)
        }
        return nil
    }

    /// Loads the bezzel NSImage from `Bundle.module` by scanning the parsed bezel index
    /// and finding an entry whose fields match and whose `models` set contains this descriptor.
    /// Falls back to `"Default"` wallpaper if `wallpaperType` is not listed for `osMajor`.
    /// - Throws: `NSError` if no matching bezel is found in the bundle.
    public func bezelImage(
        color: String,
        osMajor: String,
        wallpaperType: String = "Default",
        appearance: ScreenshotAppearance
    ) throws -> NSImage {
        guard let (family, size, model) = parsedID else {
            throw TransformError.cannotParseDeviceID(id: id)
        }

        let preferredWallpaper: String
        if let available = supportedOS[osMajor], available.contains(wallpaperType) {
            preferredWallpaper = wallpaperType
        } else {
            preferredWallpaper = "Default"
        }

        let match = ParsedBezelName.index.first { entry in
            entry.parsed.device == family
                && entry.parsed.size == size
                && entry.parsed.models.contains(model)
                && entry.parsed.color == color
                && entry.parsed.osMajor == osMajor
                && entry.parsed.wallpaper == preferredWallpaper
                && entry.parsed.appearance == appearance.rawValue
        }

        guard let entry = match, let image = NSImage(contentsOf: entry.url) else {
            throw TransformError.bezelFileNotFound(id: id, color: color)
        }
        return image
    }
}

// MARK: - Bezel index source resolution

/// Resolves the on-disk URL for a Mac bezel whose relative path (within the R2
/// layout) is `relativePath` — e.g. `"bezels/mac/device*…*Dark.png"`.
///
/// Cache-first, bundle-fallback. Returns `nil` if neither source has the file.
func macBezelURL(relativePath: String) -> URL? {
    if let cached = CatalogueStore.shared.cachedBezelURL(relativePath: relativePath) {
        return cached
    }
    // Bundle fallback: SPM's `.process("Resources")` flattens the `Bezels/Mac/`
    // subdirectory, so look up by just the filename.
    let filename = (relativePath as NSString).lastPathComponent
    let base = (filename as NSString).deletingPathExtension
    return Bundle.module.url(forResource: base, withExtension: "png")
}


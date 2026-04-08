//
//  DeviceDescriptor.swift
//  HarnessKitTransform
//

import Foundation
import AppKit

/// Describes a non-macOS, non-watch device model.
/// Loaded from platform-specific JSON files in the module bundle.
///
/// Bezel image filename pattern: `{id}{color}.png`
///
/// JSON files:
///   - `phone_devices.json`   → `DeviceDescriptor.allPhone`
///   - `pad_devices.json`     → `DeviceDescriptor.allPad`
///   - `tv_devices.json`      → `DeviceDescriptor.allTV`
///   - `vision_devices.json`  → `DeviceDescriptor.allVision`
public struct DeviceDescriptor: Codable, Equatable, Hashable, Sendable {
    /// Unique device model ID (without color), e.g. `"iPhone17"`.
    public let id: String
    public let model: String
    /// Available color variants for this device model, e.g. `["Black", "White"]`.
    public let colors: [String]
    public let runDestination: String
    public let scale: CGFloat
    public let verticalOffset: CGFloat
    public let horizontalOffset: CGFloat
    /// Corner radius in pixels at the screenshot's native resolution.
    public let screenCornerRadius: CGFloat
    /// First OS version this device supports (e.g. `"26.0"`). `nil` means no lower bound.
    public let minOSVersion: String?
    /// Last OS version this device supports (e.g. `"25.0"`). `nil` means no upper bound.
    public let maxOSVersion: String?
    /// Native screenshot width in pixels (portrait for phones, landscape for iPads/TV).
    public let nativeWidth: Int
    /// Native screenshot height in pixels.
    public let nativeHeight: Int
    /// Whether a screenshot can be placed inside this device's bezel.
    /// `false` means the device is a decoration-only image (e.g. Apple TV box, Vision Pro goggles)
    /// and is only usable in the Canvas Composer, not the Device Editor.
    public let allowsScreenshot: Bool

    private enum CodingKeys: String, CodingKey {
        case id, model, colors, color, runDestination, scale, verticalOffset, horizontalOffset,
             screenCornerRadius, minOSVersion, maxOSVersion, nativeWidth, nativeHeight, allowsScreenshot
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(String.self, forKey: .id)
        model = try c.decode(String.self, forKey: .model)
        // Backward-compat: old TV JSON has `"color": "Black"` with no `colors` array.
        if let multiColor = try? c.decode([String].self, forKey: .colors) {
            colors = multiColor
        } else {
            colors = [try c.decode(String.self, forKey: .color)]
        }
        runDestination = try c.decode(String.self, forKey: .runDestination)
        scale = try c.decode(CGFloat.self, forKey: .scale)
        verticalOffset = try c.decode(CGFloat.self, forKey: .verticalOffset)
        horizontalOffset = (try? c.decode(CGFloat.self, forKey: .horizontalOffset)) ?? 0
        screenCornerRadius = try c.decode(CGFloat.self, forKey: .screenCornerRadius)
        minOSVersion = try? c.decode(String.self, forKey: .minOSVersion)
        maxOSVersion = try? c.decode(String.self, forKey: .maxOSVersion)
        nativeWidth  = (try? c.decode(Int.self, forKey: .nativeWidth)) ?? 0
        nativeHeight = (try? c.decode(Int.self, forKey: .nativeHeight)) ?? 0
        allowsScreenshot = (try? c.decode(Bool.self, forKey: .allowsScreenshot)) ?? true
    }

    public func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id, forKey: .id)
        try c.encode(model, forKey: .model)
        try c.encode(colors, forKey: .colors)
        try c.encode(runDestination, forKey: .runDestination)
        try c.encode(scale, forKey: .scale)
        try c.encode(verticalOffset, forKey: .verticalOffset)
        try c.encode(horizontalOffset, forKey: .horizontalOffset)
        try c.encode(screenCornerRadius, forKey: .screenCornerRadius)
        try c.encodeIfPresent(minOSVersion, forKey: .minOSVersion)
        try c.encodeIfPresent(maxOSVersion, forKey: .maxOSVersion)
        if nativeWidth > 0 { try c.encode(nativeWidth, forKey: .nativeWidth) }
        if nativeHeight > 0 { try c.encode(nativeHeight, forKey: .nativeHeight) }
        if !allowsScreenshot { try c.encode(allowsScreenshot, forKey: .allowsScreenshot) }
    }

    // MARK: - Bezel image

    /// Splits an ID like `iPadAir11M4` or `iPadMiniA17Pro` into `(family, processor)`.
    /// Returns `nil` if no processor suffix is found (e.g. `iPhone17`, `iPad9thGen`).
    private var parsedFamilyAndProcessor: (family: String, processor: String)? {
        guard let range = id.range(of: #"(M\d+|A\d+[A-Za-z]*)$"#, options: .regularExpression) else {
            return nil
        }
        return (String(id[id.startIndex..<range.lowerBound]), String(id[range]))
    }

    /// Loads the bezzel NSImage for `device*{id}^color*{color}.png`.
    ///
    /// For processor-set iPad bezels (e.g. `device*iPadAir11^processors*M2+M3+M4^color*Blue.png`),
    /// falls back to an index scan when the direct filename is not found.
    /// Cache-first, bundle-fallback. Callers should `await HarnessKitCatalogue.shared.prefetch(for:)`
    /// beforehand if they want to guarantee the remote copy is used; otherwise the
    /// bundled baseline (if any) is returned.
    public func bezelImage(color: String) throws -> NSImage {
        let name = "device*\(id)^color*\(color)"
        let relativePath = "\(remoteBezelPrefix)\(name).png"
        if let cachedURL = CatalogueStore.shared.cachedBezelURL(relativePath: relativePath),
           let image = NSImage(contentsOf: cachedURL) {
            return image
        }
        if let url = Bundle.module.url(forResource: name, withExtension: "png"),
           let image = NSImage(contentsOf: url) {
            return image
        }
        // Processor-set fallback: used for iPads where one file covers multiple chip generations.
        if let (family, processor) = parsedFamilyAndProcessor {
            let match = ParsedPadBezelName.index.first { entry in
                entry.parsed.device == family
                    && entry.parsed.processors.contains(processor)
                    && entry.parsed.color == color
            }
            if let entry = match, let image = NSImage(contentsOf: entry.url) {
                return image
            }
        } else if runDestination.lowercased().contains("ipad") {
            // Device ID has no processor suffix (e.g. iPad9thGen) but the bezel
            // filename still uses the processor-set convention. Match by device + color only.
            let match = ParsedPadBezelName.index.first { entry in
                entry.parsed.device == id && entry.parsed.color == color
            }
            if let entry = match, let image = NSImage(contentsOf: entry.url) {
                return image
            }
        }
        // TV generation-set fallback: FrameBox files include ^gens*... in the filename.
        if id.hasPrefix("AppleTV") {
            let match = ParsedTVBezelName.index.first { entry in
                entry.parsed.device == id && entry.parsed.color == color
            }
            if let entry = match, let image = NSImage(contentsOf: entry.url) {
                return image
            }
        }
        throw TransformError.bezelFileNotFound(id: id, color: color)
    }

    /// Remote-path prefix this descriptor belongs to, resolved heuristically from its
    /// `runDestination`. Used only for cache lookups; bundle fallback is filename-only.
    private var remoteBezelPrefix: String {
        let dest = runDestination.lowercased()
        if dest.contains("iphone")        { return RemotePath.phoneBezelPrefix }
        if dest.contains("ipad")          { return RemotePath.padBezelPrefix }
        if dest.contains("apple tv")      { return RemotePath.tvBezelPrefix }
        if dest.contains("vision")        { return RemotePath.visionBezelPrefix }
        return RemotePath.phoneBezelPrefix
    }
}


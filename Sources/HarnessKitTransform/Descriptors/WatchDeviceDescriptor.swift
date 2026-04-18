import Foundation

/// Describes an Apple Watch device model with its available case color / band combinations.
/// Loaded from `watch_devices.json` in the module bundle.
///
/// Bezel image filename pattern: `{id}{color}{band}.png`
/// Example: `AppleWatchS1146mmAluminumJetBlackSportBandBlack.png`
public struct WatchDeviceDescriptor: Equatable, Hashable, Sendable, Codable {
    /// Unique device model ID (without color/band), e.g. `"AppleWatchS1146mmAluminum"`.
    public let id: String
    public let model: String
    /// Case color keys mapped to available band name values.
    /// Keys and values contain no spaces — used directly in PNG filenames.
    /// Example: `{"JetBlack": ["SportBandBlack", "SportBandGray"]}`.
    public let colorBands: [String: [String]]
    public let runDestination: String
    public let scale: CGFloat
    public let verticalOffset: CGFloat
    public let horizontalOffset: CGFloat
    /// Corner radius in pixels at the screenshot's native resolution.
    public let screenCornerRadius: CGFloat
    /// First watchOS version this device supports (e.g. `"11.0"`). `nil` means no lower bound.
    public let minOSVersion: String?
    /// Last watchOS version this device supports. `nil` means no upper bound.
    public let maxOSVersion: String?
    public let nativeWidth: Int
    public let nativeHeight: Int

    // MARK: - Codable

    private enum CodingKeys: String, CodingKey {
        case id, model, colorBands, runDestination, scale,
             verticalOffset, horizontalOffset, screenCornerRadius, minOSVersion, maxOSVersion,
             nativeWidth, nativeHeight
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id                 = try c.decode(String.self,              forKey: .id)
        model              = try c.decode(String.self,              forKey: .model)
        colorBands         = try c.decode([String: [String]].self,  forKey: .colorBands)
        runDestination     = try c.decode(String.self,              forKey: .runDestination)
        scale              = try c.decode(CGFloat.self,             forKey: .scale)
        verticalOffset     = try c.decode(CGFloat.self,             forKey: .verticalOffset)
        horizontalOffset   = (try? c.decode(CGFloat.self,           forKey: .horizontalOffset)) ?? 0
        screenCornerRadius = try c.decode(CGFloat.self,             forKey: .screenCornerRadius)
        minOSVersion       = try? c.decode(String.self,             forKey: .minOSVersion)
        maxOSVersion       = try? c.decode(String.self,             forKey: .maxOSVersion)
        nativeWidth        = (try? c.decode(Int.self,               forKey: .nativeWidth)) ?? 0
        nativeHeight       = (try? c.decode(Int.self,               forKey: .nativeHeight)) ?? 0
    }

    public func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id,                 forKey: .id)
        try c.encode(model,              forKey: .model)
        try c.encode(colorBands,         forKey: .colorBands)
        try c.encode(runDestination,     forKey: .runDestination)
        try c.encode(scale,              forKey: .scale)
        try c.encode(verticalOffset,     forKey: .verticalOffset)
        try c.encode(horizontalOffset,   forKey: .horizontalOffset)
        try c.encode(screenCornerRadius, forKey: .screenCornerRadius)
        try c.encodeIfPresent(minOSVersion, forKey: .minOSVersion)
        try c.encodeIfPresent(maxOSVersion, forKey: .maxOSVersion)
        if nativeWidth > 0 { try c.encode(nativeWidth, forKey: .nativeWidth) }
        if nativeHeight > 0 { try c.encode(nativeHeight, forKey: .nativeHeight) }
    }

    // MARK: - Derived

    /// Sorted case color keys available for this device.
    public var caseColors: [String] { colorBands.keys.sorted() }

    /// Band names available for a given case color.
    public func bands(for caseColor: String) -> [String] { colorBands[caseColor] ?? [] }

    // MARK: - Bezel image

    /// Splits the device `id` into `(series, size, material)` — e.g. `"AppleWatchS1146mmAluminum"` → `("S11", "46", "Aluminum")`.
    private var parsedWatchID: (series: String, size: String, material: String)? {
        let stripped = id.hasPrefix("AppleWatch") ? String(id.dropFirst("AppleWatch".count)) : id
        guard let mmRange = stripped.range(of: "mm") else { return nil }
        let beforeMM = String(stripped[stripped.startIndex..<mmRange.lowerBound])
        let material = String(stripped[mmRange.upperBound...])
        // All Apple Watch sizes are exactly 2 digits (41, 42, 44, 45, 46, 49).
        let size = String(beforeMM.suffix(2))
        let series = String(beforeMM.dropLast(2))
        return (series, size, material)
    }

    /// Loads the bezzel PlatformImage using the `key*value^key*value` index.
    /// Cache-first, bundle-fallback. See `HarnessKitCatalogue` for the prefetch contract.
    public func bezelImage(color: String, band: String) throws -> PlatformImage {
        guard let (series, size, material) = parsedWatchID else {
            throw TransformError.cannotParseDeviceID(id: id)
        }

        let key = WatchBezelKey(series: series, size: size, material: material, color: color, band: band)
        guard let url = ParsedWatchBezelName.tables.byKey[key],
              let image = BezelImageCache.shared.image(for: url, maxPixelSize: nil) else {
            throw TransformError.bezelFileNotFound(id: id, color: color)
        }
        return image
    }
}

// MARK: - Bezel index source resolution

func watchBezelURL(relativePath: String) -> URL? {
    if let cached = CatalogueStore.shared.cachedBezelURL(relativePath: relativePath) {
        return cached
    }
    let filename = (relativePath as NSString).lastPathComponent
    let base = (filename as NSString).deletingPathExtension
    return Bundle.module.url(forResource: base, withExtension: "png")
}


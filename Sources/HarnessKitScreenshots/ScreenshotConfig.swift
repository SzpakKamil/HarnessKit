import Foundation

/// Specifies which bezel to use for a specific OS version range.
/// The transform pipeline picks the first entry whose version range includes
/// the screenshot's `osVersion`. Falls back to the last entry if no match.
public struct VersionedBezel: Equatable, Sendable, Identifiable {
    public var id: UUID
    /// Inclusive lower bound, e.g. "16.0"
    public var minVersion: String
    /// Exclusive upper bound. `nil` means no upper limit.
    public var maxVersion: String?
    /// Device model ID without color, e.g. `"iPhone17"`, `"MacbookPro16M4"`.
    public var deviceID: String
    /// Color variant token, e.g. `"Black"`, `"Silver"`. Empty for TV.
    public var color: String
    /// Band name token for Apple Watch only, e.g. `"SportBandBlack"`. Empty for other platforms.
    public var band: String
    /// macOS wallpaper type token ("Default", "Custom", …). Ignored for non-macOS entries.
    public var wallpaperType: String

    public init(
        id: UUID = UUID(),
        minVersion: String,
        maxVersion: String? = nil,
        deviceID: String,
        color: String,
        band: String = "",
        wallpaperType: String = "Default"
    ) {
        self.id = id
        self.minVersion = minVersion
        self.maxVersion = maxVersion
        self.deviceID = deviceID
        self.color = color
        self.band = band
        self.wallpaperType = wallpaperType
    }
}

extension VersionedBezel: Codable {
    private enum CodingKeys: String, CodingKey {
        case id, minVersion, maxVersion, deviceID, bezelID, color, band, wallpaperType
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = (try? c.decode(UUID.self, forKey: .id)) ?? UUID()
        minVersion = try c.decode(String.self, forKey: .minVersion)
        maxVersion = try? c.decode(String.self, forKey: .maxVersion)
        // Backward-compat: old JSON used `bezelID` key
        deviceID = (try? c.decode(String.self, forKey: .deviceID))
                ?? (try? c.decode(String.self, forKey: .bezelID))
                ?? ""
        color = (try? c.decode(String.self, forKey: .color)) ?? ""
        band  = (try? c.decode(String.self, forKey: .band)) ?? ""
        wallpaperType = (try? c.decode(String.self, forKey: .wallpaperType)) ?? "Default"
    }

    public func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id, forKey: .id)
        try c.encode(minVersion, forKey: .minVersion)
        try c.encodeIfPresent(maxVersion, forKey: .maxVersion)
        try c.encode(deviceID, forKey: .deviceID)
        try c.encode(color, forKey: .color)
        try c.encode(band, forKey: .band)
        try c.encode(wallpaperType, forKey: .wallpaperType)
    }
}

public struct ScreenshotConfig: Codable, Equatable, Sendable {
    public let phoneBezel: [VersionedBezel]
    public let phoneOrientation: ScreenOrientation
    public let padBezel: [VersionedBezel]
    public let padOrientation: ScreenOrientation
    public let watchBezel: [VersionedBezel]
    public let tvBezel: [VersionedBezel]
    public let macBezel: [VersionedBezel]
    public let visionBezel: [VersionedBezel]
    public let resolution: ScreenshotResolution

    /// Pre-sorted (descending by `minVersion`) bezel arrays keyed by OS,
    /// computed once at init / decode. `matchedBezel(for:)` reads from this
    /// dict instead of sorting on every call. Not serialized — recomputed on
    /// every decode (same pattern as `Manifest.filesByPrefix`).
    private let _sortedBezelsByOS: [TargetOS: [VersionedBezel]]

    private enum CodingKeys: String, CodingKey {
        case phoneBezel, phoneOrientation, padBezel, padOrientation,
             watchBezel, tvBezel, macBezel, visionBezel, resolution
    }

    public init(
        phoneBezel: [VersionedBezel],
        phoneOrientation: ScreenOrientation,
        padBezel: [VersionedBezel],
        padOrientation: ScreenOrientation,
        watchBezel: [VersionedBezel],
        macBezel: [VersionedBezel],
        tvBezel: [VersionedBezel],
        visionBezel: [VersionedBezel] = [],
        resolution: ScreenshotResolution
    ) {
        self.phoneBezel = phoneBezel
        self.phoneOrientation = phoneOrientation
        self.padBezel = padBezel
        self.padOrientation = padOrientation
        self.watchBezel = watchBezel
        self.macBezel = macBezel
        self.tvBezel = tvBezel
        self.visionBezel = visionBezel
        self.resolution = resolution
        self._sortedBezelsByOS = Self.buildSortedBezels(
            iOS: phoneBezel, iPadOS: padBezel, watchOS: watchBezel,
            macOS: macBezel, tvOS: tvBezel
        )
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        let phoneBezel  = try c.decode([VersionedBezel].self, forKey: .phoneBezel)
        let phoneOrient = try c.decode(ScreenOrientation.self, forKey: .phoneOrientation)
        let padBezel    = try c.decode([VersionedBezel].self, forKey: .padBezel)
        let padOrient   = try c.decode(ScreenOrientation.self, forKey: .padOrientation)
        let watchBezel  = try c.decode([VersionedBezel].self, forKey: .watchBezel)
        let tvBezel     = try c.decode([VersionedBezel].self, forKey: .tvBezel)
        let macBezel    = try c.decode([VersionedBezel].self, forKey: .macBezel)
        let visionBezel = (try? c.decode([VersionedBezel].self, forKey: .visionBezel)) ?? []
        let resolution  = try c.decode(ScreenshotResolution.self, forKey: .resolution)
        self.init(
            phoneBezel: phoneBezel,
            phoneOrientation: phoneOrient,
            padBezel: padBezel,
            padOrientation: padOrient,
            watchBezel: watchBezel,
            macBezel: macBezel,
            tvBezel: tvBezel,
            visionBezel: visionBezel,
            resolution: resolution
        )
    }

    /// Equality skips `_sortedBezelsByOS` — it's a deterministic function of
    /// the bezel arrays, so comparing it would just duplicate work.
    public static func == (lhs: ScreenshotConfig, rhs: ScreenshotConfig) -> Bool {
        lhs.phoneBezel       == rhs.phoneBezel       &&
        lhs.phoneOrientation == rhs.phoneOrientation &&
        lhs.padBezel         == rhs.padBezel         &&
        lhs.padOrientation   == rhs.padOrientation   &&
        lhs.watchBezel       == rhs.watchBezel       &&
        lhs.tvBezel          == rhs.tvBezel          &&
        lhs.macBezel         == rhs.macBezel         &&
        lhs.visionBezel      == rhs.visionBezel      &&
        lhs.resolution       == rhs.resolution
    }

    private static func buildSortedBezels(
        iOS phoneBezel: [VersionedBezel],
        iPadOS padBezel: [VersionedBezel],
        watchOS watchBezel: [VersionedBezel],
        macOS macBezel: [VersionedBezel],
        tvOS tvBezel: [VersionedBezel]
    ) -> [TargetOS: [VersionedBezel]] {
        let comparator: (VersionedBezel, VersionedBezel) -> Bool = {
            $0.minVersion.compare($1.minVersion, options: .numeric) == .orderedDescending
        }
        return [
            .iOS:     phoneBezel.sorted(by: comparator),
            .iPadOS:  padBezel.sorted(by: comparator),
            .watchOS: watchBezel.sorted(by: comparator),
            .macOS:   macBezel.sorted(by: comparator),
            .tvOS:    tvBezel.sorted(by: comparator),
        ]
    }

    // MARK: - Factory

    /// Loads a `ScreenshotConfig` from a JSON file at the given URL.
    /// Returns `.defaults` if the file doesn't exist or can't be decoded.
    ///
    /// The config JSON should live in your project (e.g. Application Support or
    /// a bundle resource), not inside the HarnessKit package.
    ///
    /// ```swift
    /// let config = ScreenshotConfig.load(from: myConfigURL)
    /// ```
    public static func load(from url: URL) -> ScreenshotConfig {
        guard let data = try? Data(contentsOf: url),
              let config = try? JSONDecoder().decode(ScreenshotConfig.self, from: data) else {
            return .defaults
        }
        return config
    }

    // MARK: - Defaults

    public static var defaults: ScreenshotConfig {
        ScreenshotConfig(
            phoneBezel: [
                VersionedBezel(minVersion: "16.0", deviceID: "iPhone17", color: "Black")
            ],
            phoneOrientation: .portrait,
            padBezel: [
                VersionedBezel(minVersion: "17.0", deviceID: "iPadAir11M4", color: "Blue")
            ],
            padOrientation: .landscape,
            watchBezel: [
                VersionedBezel(minVersion: "11.0", deviceID: "AppleWatchS1146mmAluminum",
                               color: "JetBlack", band: "SportBandBlack")
            ],
            macBezel: [
                VersionedBezel(minVersion: "15.0", deviceID: "MacbookPro16M4", color: "Silver")
            ],
            tvBezel: [
                VersionedBezel(minVersion: "18.0", deviceID: "AppleTVFrame", color: "Default")
            ],
            resolution: .default
        )
    }

    // MARK: - Version-Aware Bezel Resolution

    /// Returns the matched `VersionedBezel` (full struct) for `screenshot`.
    /// Falls back to the highest-minVersion entry when no exact match. Returns `nil` for visionOS.
    ///
    /// Reads from the pre-sorted `_sortedBezelsByOS` cache built at init —
    /// no per-call sort. The cache stores entries descending by `minVersion`
    /// so the version-match loop walks highest → lowest, and the no-match
    /// fallback is `sorted.first`.
    public func matchedBezel(for screenshot: Screenshot) -> VersionedBezel? {
        guard let sorted = _sortedBezelsByOS[screenshot.os], !sorted.isEmpty else {
            return nil
        }

        if let version = screenshot.osVersion {
            for entry in sorted {
                let meetsMin = versionCompare(version, isGreaterThanOrEqualTo: entry.minVersion)
                let meetsMax: Bool
                if let max = entry.maxVersion {
                    meetsMax = versionCompare(version, isLessThan: max)
                } else {
                    meetsMax = true
                }
                if meetsMin && meetsMax { return entry }
            }
        }

        return sorted.first
    }
}

// MARK: - Private Helpers

private func versionCompare(_ version: String, isGreaterThanOrEqualTo other: String) -> Bool {
    version.compare(other, options: .numeric) != .orderedAscending
}

private func versionCompare(_ version: String, isLessThan other: String) -> Bool {
    version.compare(other, options: .numeric) == .orderedAscending
}

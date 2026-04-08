//
//  ScreenshotConfig.swift
//  HarnessKitScreenshots
//

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

public struct ScreenshotConfig: Codable, Equatable {
    public var phoneBezel: [VersionedBezel]
    public var phoneOrientation: ScreenOrientation
    public var padBezel: [VersionedBezel]
    public var padOrientation: ScreenOrientation
    public var watchBezel: [VersionedBezel]
    public var tvBezel: [VersionedBezel]
    public var macBezel: [VersionedBezel]
    public var visionBezel: [VersionedBezel]
    public var resolution: ScreenshotResolution

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
    public func matchedBezel(for screenshot: Screenshot) -> VersionedBezel? {
        let candidates: [VersionedBezel]
        switch screenshot.os {
        case .iOS:      candidates = phoneBezel
        case .iPadOS:   candidates = padBezel
        case .watchOS:  candidates = watchBezel
        case .macOS:    candidates = macBezel
        case .tvOS:     candidates = tvBezel
        case .visionOS: return nil
        }
        guard !candidates.isEmpty else { return nil }

        if let version = screenshot.osVersion {
            let sorted = candidates.sorted {
                $0.minVersion.compare($1.minVersion, options: .numeric) == .orderedDescending
            }
            for entry in sorted {
                let meetsMin = _versionCompare(version, isGreaterThanOrEqualTo: entry.minVersion)
                let meetsMax: Bool
                if let max = entry.maxVersion {
                    meetsMax = _versionCompare(version, isLessThan: max)
                } else {
                    meetsMax = true
                }
                if meetsMin && meetsMax { return entry }
            }
        }

        return candidates.sorted {
            $0.minVersion.compare($1.minVersion, options: .numeric) == .orderedDescending
        }.first
    }
}

// MARK: - Private Helpers

private func _versionCompare(_ version: String, isGreaterThanOrEqualTo other: String) -> Bool {
    version.compare(other, options: .numeric) != .orderedAscending
}

private func _versionCompare(_ version: String, isLessThan other: String) -> Bool {
    version.compare(other, options: .numeric) == .orderedAscending
}

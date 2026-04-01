//
//  ScreenshotConfig.swift
//  HarnessKitScreenshots
//

import Foundation

/// Specifies which bezel to use for a specific OS version range.
/// The transform pipeline picks the first entry whose version range includes
/// the screenshot's `osVersion`. Falls back to the last entry if no match.
public struct VersionedBezel: Codable, Equatable, Sendable {
    /// Inclusive lower bound, e.g. "16.0"
    public var minVersion: String
    /// Exclusive upper bound. `nil` means no upper limit.
    public var maxVersion: String?
    /// Bezel ID string, resolved to a concrete `BezelDescriptor` by HarnessKitTransform.
    public var bezelID: String

    public init(minVersion: String, maxVersion: String? = nil, bezelID: String) {
        self.minVersion = minVersion
        self.maxVersion = maxVersion
        self.bezelID = bezelID
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
    public var resolution: ScreenshotResolution

    public init(
        phoneBezel: [VersionedBezel],
        phoneOrientation: ScreenOrientation,
        padBezel: [VersionedBezel],
        padOrientation: ScreenOrientation,
        watchBezel: [VersionedBezel],
        macBezel: [VersionedBezel],
        tvBezel: [VersionedBezel],
        resolution: ScreenshotResolution
    ) {
        self.phoneBezel = phoneBezel
        self.phoneOrientation = phoneOrientation
        self.padBezel = padBezel
        self.padOrientation = padOrientation
        self.watchBezel = watchBezel
        self.macBezel = macBezel
        self.tvBezel = tvBezel
        self.resolution = resolution
    }

    // MARK: - Factory
    @MainActor
    public static func load() -> ScreenshotConfig {
        guard let url = Bundle.module.url(forResource: "config", withExtension: "json") else {
            return .defaults
        }
        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode(ScreenshotConfig.self, from: data)
        } catch {
            return .defaults
        }
    }

    // MARK: - Defaults

    public static var defaults: ScreenshotConfig {
        ScreenshotConfig(
            phoneBezel: [
                VersionedBezel(minVersion: "16.0", maxVersion: "26.0", bezelID: "iPhone16Black"),
                VersionedBezel(minVersion: "26.0", bezelID: "iPhone17Black")
            ],
            phoneOrientation: .portrait,
            padBezel: [
                VersionedBezel(minVersion: "16.0", bezelID: "iPadMiniA17ProStarlight")
            ],
            padOrientation: .landscape,
            watchBezel: [
                VersionedBezel(minVersion: "11.0", bezelID: "AppleWatchS1146mmAluminumJetBlackSportBandBlack")
            ],
            macBezel: [
                VersionedBezel(minVersion: "15.0", bezelID: "MacbookPro16M4Silver")
            ],
            tvBezel: [
                VersionedBezel(minVersion: "18.0", bezelID: "AppleTVFrame")
            ],
            resolution: .default
        )
    }

    // MARK: - Version-Aware Bezel Resolution
    public func bezelID(for screenshot: Screenshot) -> String? {
        let candidates: [VersionedBezel]
        switch screenshot.os {
        case .iOS:
            candidates = phoneBezel
        case .iPadOS:
            candidates = padBezel
        case .watchOS:
            candidates = watchBezel
        case .macOSTahoe, .macOSSequoia:
            candidates = macBezel
        case .tvOS:
            candidates = tvBezel
        case .visionOS:
            return nil
        }

        guard !candidates.isEmpty else { return nil }

        if let version = screenshot.osVersion {
            for entry in candidates {
                let meetsMin = _versionCompare(version, isGreaterThanOrEqualTo: entry.minVersion)
                let meetsMax: Bool
                if let max = entry.maxVersion {
                    meetsMax = _versionCompare(version, isLessThan: max)
                } else {
                    meetsMax = true
                }
                if meetsMin && meetsMax {
                    return entry.bezelID
                }
            }
        }

        return candidates.last?.bezelID
    }
}

// MARK: - Private Helpers

private func _versionCompare(_ version: String, isGreaterThanOrEqualTo other: String) -> Bool {
    version.compare(other, options: .numeric) != .orderedAscending
}

private func _versionCompare(_ version: String, isLessThan other: String) -> Bool {
    version.compare(other, options: .numeric) == .orderedAscending
}

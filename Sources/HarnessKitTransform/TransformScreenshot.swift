//
//  TransformScreenshot.swift
//  HarnessKitTransform
//

import AppKit
import HarnessKitScreenshots

/// Resolves the best-matching bezel for a screenshot based on the versioned config.
/// Falls back to the last config entry if no version matches or `osVersion` is nil.
public func resolveBezel<B: BezelDescriptor>(
    from candidates: [VersionedBezel],
    for screenshot: Screenshot,
    bezelType: B.Type
) -> B? {
    guard !candidates.isEmpty else { return nil }

    var targetID: String?

    if let version = screenshot.osVersion {
        let sorted = candidates.sorted {
            $0.minVersion.compare($1.minVersion, options: .numeric) == .orderedDescending
        }
        for entry in sorted {
            let meetsMin = version.compare(entry.minVersion, options: .numeric) != .orderedAscending
            let meetsMax: Bool
            if let max = entry.maxVersion {
                meetsMax = version.compare(max, options: .numeric) == .orderedAscending
            } else {
                meetsMax = true
            }
            if meetsMin && meetsMax {
                targetID = entry.bezelID
                break
            }
        }
    }

    let resolvedID = targetID ?? candidates.sorted {
        $0.minVersion.compare($1.minVersion, options: .numeric) == .orderedDescending
    }.first?.bezelID
    guard let id = resolvedID else { return nil }
    return try? B.bezel(for: id)
}

/// Processes a screenshot through the full platform-specific pipeline and returns
/// the resulting image. Does not save — call `saveResults(image:name:to:)` afterwards.
///
/// - Throws: `TransformError` if a required bezel is missing.
public nonisolated func processScreenshot(image: NSImage, screenshot: Screenshot, config: ScreenshotConfig) throws -> NSImage {
    switch screenshot.os {
    case .macOSTahoe, .macOSSequoia:
        return try processScreenshotMacOS(image: image, config: config, screenshot: screenshot)
    case .iOS:
        return try processScreenshotIOS(image: image, config: config, screenshot: screenshot)
    case .iPadOS:
        return try processScreenshotIPadOS(image: image, config: config, screenshot: screenshot)
    case .watchOS:
        return try processScreenshotWatchOS(image: image, config: config, screenshot: screenshot)
    case .tvOS:
        return try processScreenshotTVOS(image: image, config: config, screenshot: screenshot)
    case .visionOS:
        return processScreenshotVisionOS(image: image, config: config, screenshot: screenshot)
    }
}

/// Processes a screenshot and saves the result to `outputDirectory`.
///
/// - Parameters:
///   - image: The raw screenshot image captured during testing.
///   - screenshot: Metadata describing the screenshot (OS, appearance, crop, etc.).
///   - config: Versioned bezel and resolution config.
///   - outputDirectory: Directory where the resulting PNG will be written.
/// - Throws: `TransformError` if a required bezel is missing or saving fails.
public nonisolated func transformScreenshot(
    image: NSImage,
    screenshot: Screenshot,
    config: ScreenshotConfig,
    outputDirectory: URL
) throws {
    let result = try processScreenshot(image: image, screenshot: screenshot, config: config)
    try saveResults(image: result, name: screenshot.prettyName(), to: outputDirectory)
}

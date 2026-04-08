//
//  TransformScreenshot.swift
//  HarnessKitTransform
//

import AppKit
import HarnessKitScreenshots

/// Processes a screenshot through the full platform-specific pipeline and returns
/// the resulting image. Does not save — call `saveResults(image:name:to:)` afterwards.
///
/// - Throws: `TransformError` if a required bezel is missing.
public nonisolated func processScreenshot(image: NSImage, screenshot: Screenshot, config: ScreenshotConfig) throws -> NSImage {
    switch screenshot.os {
    case .macOS:
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
    try saveResults(image: result, screenshot: screenshot, to: outputDirectory)
}

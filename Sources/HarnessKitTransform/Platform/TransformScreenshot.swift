import Foundation
import HarnessKitScreenshots

/// Processes a screenshot through the full platform-specific pipeline and returns
/// the resulting image. Does not save — call `saveResults(image:name:to:)` afterwards.
///
/// - Throws: `TransformError` if a required bezel is missing.
public nonisolated func processScreenshot(image: PlatformImage, screenshot: Screenshot, config: ScreenshotConfig) throws -> PlatformImage {
    try autoreleasepool {
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
    image: PlatformImage,
    screenshot: Screenshot,
    config: ScreenshotConfig,
    outputDirectory: URL
) throws {
    try autoreleasepool {
        // Cancellation plumbing for the bulk API: pipeline stages
        // silently `break` their inner loops on cancellation and return
        // a partial `PlatformImage`. Without these checks we'd persist
        // that partial render to disk. Top check skips already-cancelled
        // tasks; mid check skips persisting after cancellation lands
        // during processing.
        try Task.checkCancellation()
        let result = try processScreenshot(image: image, screenshot: screenshot, config: config)
        try Task.checkCancellation()
        try saveResults(image: result, screenshot: screenshot, to: outputDirectory)
    }
}

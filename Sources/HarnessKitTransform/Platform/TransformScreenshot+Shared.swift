import Foundation
import CoreGraphics
import HarnessKitScreenshots

/// Resolves the matched bezel and loads the descriptor (no image load) for
/// `DeviceDescriptor`-based platforms (iOS, iPadOS, tvOS, watchOS uses its own).
/// The descriptor's `scale` / offsets / corner radius are needed by both the
/// bezel and no-bezel paths; the bezel image itself is only needed by the
/// bezel path. Splitting this lets `Screenshot(addBezel: false)` callers
/// transform without a populated catalogue.
func resolveDeviceDescriptor(
    screenshot: Screenshot,
    config: ScreenshotConfig,
    catalogue: [DeviceDescriptor]
) throws -> (descriptor: DeviceDescriptor, matched: VersionedBezel) {
    guard let matched = config.matchedBezel(for: screenshot) else {
        throw TransformError.bezelNotFound(screenshotID: screenshot.id)
    }
    let descriptor: DeviceDescriptor
    do {
        descriptor = try DeviceDescriptor.descriptor(for: matched.deviceID, in: catalogue)
    } catch {
        throw TransformError.bezelNotFound(screenshotID: screenshot.id)
    }
    return (descriptor, matched)
}

/// Loads the bezel image for the given descriptor + matched bezel. Wraps the
/// descriptor's throwing loader in a `TransformError.bezelImageMissing` so
/// callers see the higher-level error.
func loadBezelImage(
    descriptor: DeviceDescriptor,
    matched: VersionedBezel
) throws -> PlatformImage {
    do {
        return try descriptor.bezelImage(color: matched.color)
    } catch {
        throw TransformError.bezelImageMissing(bezelID: matched.deviceID)
    }
}

/// Applies the no-bezel fallback pipeline: prepare → scale → orient → shadows → background → crop → resolution.
func applyNoBezelPipeline(
    image: PlatformImage,
    screenshot: Screenshot,
    config: ScreenshotConfig,
    scale: CGFloat,
    orientation: ScreenOrientation? = nil
) -> PlatformImage {
    autoreleasepool {
        // iOS/iPadOS L→L fast path: input is landscape AND target is landscape.
        // Current pipeline rotates -π/2 in `prepareScreenshot` then +π/2 in
        // `applyOrientation`, netting identity on the screenshot pixels.
        // Skip both rotations — for uniform scaling with a symmetric kernel,
        // rotation and scaling commute, so the output is bit-for-bit identical.
        let inputSize = imageSize(image)
        let inputIsLandscape = inputSize.width > inputSize.height
        let canSkipRotations = (screenshot.os == .iOS || screenshot.os == .iPadOS)
            && orientation == .landscape
            && inputIsLandscape

        let prepared = canSkipRotations
            ? normalizeOrientation(image)
            : prepareScreenshot(image: image, os: screenshot.os)
        var result = scaleToBezel(image: prepared, factor: scale)
        if !canSkipRotations, let orientation {
            result = applyOrientation(image: result, orientation: orientation)
        }
        let compSize = result.size
        let compCenter = CGPoint(x: compSize.width / 2, y: compSize.height / 2)
        result = applyShadows(image: result, shadows: screenshot.shadows, compositionSize: compSize, compositionCenter: compCenter)
        result = addBackground(image: result, background: screenshot.background)
        result = cropImage(image: result, crop: screenshot.crop)
        return adjustResolution(image: result, resolution: config.resolution)
    }
}

//
//  TransformScreenshot+Shared.swift
//  HarnessKitTransform
//
//  Shared helpers for platform-specific screenshot transform functions.
//

import AppKit
import HarnessKitScreenshots

/// Resolves the matched bezel, loads the descriptor, and loads the bezel image
/// for `DeviceDescriptor`-based platforms (iOS, iPadOS, tvOS).
func resolveDeviceBezel(
    screenshot: Screenshot,
    config: ScreenshotConfig,
    catalogue: [DeviceDescriptor]
) throws -> (descriptor: DeviceDescriptor, bezelImage: NSImage, matched: VersionedBezel) {
    guard let matched = config.matchedBezel(for: screenshot) else {
        throw TransformError.bezelNotFound(screenshotID: screenshot.id)
    }
    let descriptor: DeviceDescriptor
    do {
        descriptor = try DeviceDescriptor.descriptor(for: matched.deviceID, in: catalogue)
    } catch {
        throw TransformError.bezelNotFound(screenshotID: screenshot.id)
    }
    let bezelImage: NSImage
    do {
        bezelImage = try descriptor.bezelImage(color: matched.color)
    } catch {
        throw TransformError.bezelImageMissing(bezelID: matched.deviceID)
    }
    return (descriptor, bezelImage, matched)
}

/// Applies the no-bezel fallback pipeline: prepare → scale → orient → shadows → background → crop → resolution.
func applyNoBezelPipeline(
    image: NSImage,
    screenshot: Screenshot,
    config: ScreenshotConfig,
    scale: CGFloat,
    orientation: ScreenOrientation? = nil
) -> NSImage {
    let prepared = prepareScreenshot(image: image, os: screenshot.os)
    var result = scaleToBezel(image: prepared, factor: scale)
    if let orientation {
        result = applyOrientation(image: result, orientation: orientation)
    }
    let compSize = result.size
    let compCenter = NSPoint(x: compSize.width / 2, y: compSize.height / 2)
    result = applyShadows(image: result, shadows: screenshot.shadows, compositionSize: compSize, compositionCenter: compCenter)
    result = addBackground(image: result, background: screenshot.background)
    result = cropImage(image: result, crop: screenshot.crop)
    return adjustResolution(image: result, resolution: config.resolution)
}

//
//  TransformScreenshot+macOS.swift
//  HarnessKitTransform
//

import AppKit
import HarnessKitScreenshots

nonisolated func processScreenshotMacOS(image: NSImage, config: ScreenshotConfig, screenshot: Screenshot) throws -> NSImage {
    guard let matched = config.matchedBezel(for: screenshot) else {
        throw TransformError.bezelNotFound(screenshotID: screenshot.id)
    }

    let descriptor: MacDeviceDescriptor
    do {
        descriptor = try MacDeviceDescriptor.descriptor(for: matched.deviceID)
    } catch {
        throw TransformError.bezelNotFound(screenshotID: screenshot.id)
    }

    // Extract major OS version string, e.g. "26.0" → "26"
    let osMajor = screenshot.osVersion
        .flatMap { $0.split(separator: ".").first.map(String.init) }
        ?? "15"

    let bezelImage: NSImage
    do {
        bezelImage = try descriptor.bezelImage(
            color: matched.color,
            osMajor: osMajor,
            wallpaperType: matched.wallpaperType,
            appearance: screenshot.appearance
        )
    } catch {
        throw TransformError.bezelImageMissing(bezelID: matched.deviceID)
    }

    if screenshot.addBezel {
        let params = BezelPipelineParams(
            os: screenshot.os,
            bezelImage: bezelImage,
            scale: descriptor.scale,
            verticalOffset: descriptor.verticalOffset,
            horizontalOffset: descriptor.horizontalOffset,
            cornerRadius: 0,
            screenshotOnTop: true,
            background: screenshot.background,
            shadows: screenshot.shadows,
            crop: screenshot.crop,
            resolution: config.resolution
        )
        return applyBezelPipeline(image: image, params: params)
    }

    return applyNoBezelPipeline(
        image: image, screenshot: screenshot, config: config,
        scale: descriptor.scale
    )
}

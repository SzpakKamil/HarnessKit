//
//  TransformScreenshot+watchOS.swift
//  HarnessKitTransform
//

import AppKit
import HarnessKitScreenshots

nonisolated func processScreenshotWatchOS(image: NSImage, config: ScreenshotConfig, screenshot: Screenshot) throws -> NSImage {
    guard let matched = config.matchedBezel(for: screenshot) else {
        throw TransformError.bezelNotFound(screenshotID: screenshot.id)
    }

    let descriptor: WatchDeviceDescriptor
    do {
        descriptor = try WatchDeviceDescriptor.descriptor(for: matched.deviceID)
    } catch {
        throw TransformError.bezelNotFound(screenshotID: screenshot.id)
    }

    let bezelImage: NSImage
    do {
        bezelImage = try descriptor.bezelImage(color: matched.color, band: matched.band)
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
            cornerRadius: descriptor.screenCornerRadius,
            screenshotOnTop: false,
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

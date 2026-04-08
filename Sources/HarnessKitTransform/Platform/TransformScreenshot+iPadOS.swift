//
//  TransformScreenshot+iPadOS.swift
//  HarnessKitTransform
//

import AppKit
import HarnessKitScreenshots

nonisolated func processScreenshotIPadOS(image: NSImage, config: ScreenshotConfig, screenshot: Screenshot) throws -> NSImage {
    let (descriptor, bezelImage, _) = try resolveDeviceBezel(
        screenshot: screenshot, config: config, catalogue: DeviceDescriptor.allPad
    )

    if screenshot.addBezel {
        let params = BezelPipelineParams(
            os: screenshot.os,
            bezelImage: bezelImage,
            scale: descriptor.scale,
            verticalOffset: descriptor.verticalOffset,
            horizontalOffset: descriptor.horizontalOffset,
            cornerRadius: descriptor.screenCornerRadius,
            screenshotOnTop: false,
            orientation: screenshot.orientation ?? config.padOrientation,
            background: screenshot.background,
            shadows: screenshot.shadows,
            crop: screenshot.crop,
            resolution: config.resolution
        )
        return applyBezelPipeline(image: image, params: params)
    }

    return applyNoBezelPipeline(
        image: image, screenshot: screenshot, config: config,
        scale: descriptor.scale,
        orientation: screenshot.orientation ?? config.padOrientation
    )
}

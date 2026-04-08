//
//  TransformScreenshot+visionOS.swift
//  HarnessKitTransform
//

import AppKit
import HarnessKitScreenshots

nonisolated func processScreenshotVisionOS(image: NSImage, config: ScreenshotConfig, screenshot: Screenshot) -> NSImage {
    // visionOS has no bezel compositing — use a neutral scale factor of 1.0
    let preparedScreenshot = prepareScreenshot(image: image, os: screenshot.os)
    let scaledImage = scaleToBezel(image: preparedScreenshot, factor: 1.0)
    let compSize = scaledImage.size
    let compCenter = NSPoint(x: compSize.width / 2, y: compSize.height / 2)
    let shadowedImage = applyShadows(image: scaledImage, shadows: screenshot.shadows, compositionSize: compSize, compositionCenter: compCenter)
    let backgroundColoredImage = addBackground(image: shadowedImage, background: screenshot.background)
    let croppedImage = cropImage(image: backgroundColoredImage, crop: screenshot.crop)
    return adjustResolution(image: croppedImage, resolution: config.resolution)
}

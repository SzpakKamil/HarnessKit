//
//  TransformScreenshot+visionOS.swift
//  HarnessKitTransform
//

import AppKit
import HarnessKitScreenshots

public nonisolated func processScreenshotVisionOS(image: NSImage, config: ScreenshotConfig, screenshot: Screenshot) -> NSImage {
    // visionOS has no bezel compositing — use a neutral scale factor of 1.0
    let preparedScreenshot = prepareScreenshot(image: image, os: screenshot.os)
    let scaledImage = scaleToBezel(image: preparedScreenshot, factor: 1.0)
    let backgroundColoredImage = addBackgroundColor(image: scaledImage, color: screenshot.backgroundHex)
    let croppedImage = cropImage(image: backgroundColoredImage, crop: screenshot.crop)
    return adjustResolution(image: croppedImage, resolution: config.resolution)
}

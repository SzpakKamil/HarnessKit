//
//  TransformScreenshot+macOS.swift
//  HarnessKitTransform
//

import AppKit
import HarnessKitScreenshots

public nonisolated func processScreenshotMacOS(image: NSImage, config: ScreenshotConfig, screenshot: Screenshot) throws -> NSImage {
    guard let bezelCase = resolveBezel(from: config.macBezel, for: screenshot, bezelType: MacBezel.self) else {
        throw TransformError.bezelNotFound(screenshotID: screenshot.id)
    }

    let bezelImage: NSImage
    do {
        bezelImage = try bezelCase.borderImage(os: screenshot.os, appearance: screenshot.appearance)
    } catch {
        throw TransformError.bezelImageMissing(bezelID: bezelCase.id)
    }

    let preparedScreenshot = prepareScreenshot(image: image, scaleMacOS: !screenshot.addBezel, os: screenshot.os)

    var scaledImage = preparedScreenshot
    var bezeledImage = scaledImage

    if screenshot.addBezel {
        scaledImage = scaleToBezel(image: preparedScreenshot, factor: bezelCase.scale)
        bezeledImage = placeBezel(
            image: scaledImage,
            bezel: bezelImage,
            verticalOffset: bezelCase.verticalOffset,
            screenshotOnTop: true
        )
    }

    let backgroundColoredImage = addBackgroundColor(image: bezeledImage, color: screenshot.backgroundHex)
    let croppedImage = cropImage(image: backgroundColoredImage, crop: screenshot.crop)
    return adjustResolution(image: croppedImage, resolution: config.resolution)
}

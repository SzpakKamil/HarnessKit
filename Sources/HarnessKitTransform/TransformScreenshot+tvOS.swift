//
//  TransformScreenshot+tvOS.swift
//  HarnessKitTransform
//

import AppKit
import HarnessKitScreenshots

public nonisolated func processScreenshotTVOS(image: NSImage, config: ScreenshotConfig, screenshot: Screenshot) throws -> NSImage {
    guard let bezelCase = resolveBezel(from: config.tvBezel, for: screenshot, bezelType: OtherBezel.self) else {
        throw TransformError.bezelNotFound(screenshotID: screenshot.id)
    }

    let bezelImage: NSImage
    do {
        bezelImage = try bezelCase.borderImage(os: screenshot.os, appearance: screenshot.appearance)
    } catch {
        throw TransformError.bezelImageMissing(bezelID: bezelCase.id)
    }

    let preparedScreenshot = prepareScreenshot(image: image, os: screenshot.os)
    let scaledImage = scaleToBezel(image: preparedScreenshot, factor: bezelCase.scale)

    var bezeledImage = scaledImage
    if screenshot.addBezel {
        bezeledImage = placeBezel(
            image: scaledImage,
            bezel: bezelImage,
            verticalOffset: bezelCase.verticalOffset,
            screenshotOnTop: false
        )
    }

    let backgroundColoredImage = addBackgroundColor(image: bezeledImage, color: screenshot.backgroundHex)
    let croppedImage = cropImage(image: backgroundColoredImage, crop: screenshot.crop)
    return adjustResolution(image: croppedImage, resolution: config.resolution)
}

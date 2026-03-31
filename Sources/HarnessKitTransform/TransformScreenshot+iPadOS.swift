//
//  TransformScreenshot+iPadOS.swift
//  HarnessKitTransform
//

import AppKit
import HarnessKitScreenshots

public nonisolated func processScreenshotIPadOS(image: NSImage, config: ScreenshotConfig, screenshot: Screenshot) throws -> NSImage {
    guard let bezelCase = resolveBezel(from: config.padBezel, for: screenshot, bezelType: PadBezel.self) else {
        throw TransformError.bezelNotFound(screenshotID: screenshot.id)
    }

    let bezelImage: NSImage
    do {
        bezelImage = try bezelCase.borderImage(os: screenshot.os, appearance: screenshot.appearance)
    } catch {
        throw TransformError.bezelImageMissing(bezelID: bezelCase.id)
    }

    let preparedScreenshot = prepareScreenshot(image: image, os: screenshot.os)

    var maskedScreenshot = preparedScreenshot
    if screenshot.addBezel {
        maskedScreenshot = maskScreenshot(image: preparedScreenshot, bezel: bezelCase)
    }

    let scaledImage = scaleToBezel(image: maskedScreenshot, factor: bezelCase.scale)

    var bezeledImage = scaledImage
    if screenshot.addBezel {
        bezeledImage = placeBezel(
            image: scaledImage,
            bezel: bezelImage,
            verticalOffset: bezelCase.verticalOffset,
            screenshotOnTop: false
        )
    }

    let orientedImage = applyOrientation(
        image: bezeledImage,
        orientation: screenshot.orientation ?? config.padOrientation
    )
    let backgroundColoredImage = addBackgroundColor(image: orientedImage, color: screenshot.backgroundHex)
    let croppedImage = cropImage(image: backgroundColoredImage, crop: screenshot.crop)
    return adjustResolution(image: croppedImage, resolution: config.resolution)
}

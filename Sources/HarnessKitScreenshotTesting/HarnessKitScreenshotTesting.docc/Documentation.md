# ``HarnessKitScreenshotTesting``

XCTest functions that capture annotated screenshots during UI tests.

@Metadata {
    @SupportedLanguage(swift)
    @Available(iOS, introduced: "14.0")
    @Available(iPadOS, introduced: "14.0")
    @Available(macOS, introduced: "11.0")
    @Available(tvOS, introduced: "14.0")
    @Available(watchOS, introduced: "10.0")
    @Available(visionOS, introduced: "1.0")
    @Available(swift, introduced: "5.9")
    @Available(Xcode, introduced: "15.0")
    @DocumentationExtension(mergeBehavior: override)
}

@Options {
    @AutomaticTitleHeading(enabled)
    @AutomaticSeeAlso(disabled)
    @AutomaticArticleSubheading(disabled)
}

## Overview

`HarnessKitScreenshotTesting` is the capture side of the screenshot pipeline. Five top-level functions handle device appearance, simulator rotation, screen capture, and PNG attachment. The library imports `XCTest`, so it belongs in your UI test bundle and nowhere else.

It depends on `HarnessKitScreenshots` for the `Screenshot` model type.

### What It Does

- Sets `XCUIDevice.shared.appearance` from `Screenshot.appearance`.
- Stamps `Screenshot.osVersion` with the running simulator's version.
- Captures the screen, rounded to 35 points on macOS, full-bleed elsewhere.
- Attaches the PNG to the test with `Screenshot.screenshotName()` as its name.
- Rotates the iOS simulator with `updateOrientation(phone:pad:)` or `setOrientation(to:)`.

### What It Does Not Do

- No image compositing. No bezels, shadows, or backgrounds.
- No navigation. That is `HarnessKitTesting`.
- No model types. Those live in `HarnessKitScreenshots`.

## Getting Started

@Links(visualStyle: detailedGrid) {
    - <doc:AboutHarnessKitScreenshotTesting>
    - <doc:SetUpScreenshotTesting>
}

## Topics

### Essentials

- <doc:AboutHarnessKitScreenshotTesting>
- <doc:SetUpScreenshotTesting>

### Capture

- ``captureScreenshot(screenshot:app:sleepSeconds:customActions:add:)``

### Orientation

- ``updateOrientation(phone:pad:)``
- ``setOrientation(to:)``

### Appearance

- ``resetTheme(to:)``
- ``currentTheme()``

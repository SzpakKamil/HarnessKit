# ``HarnessKitScreenshotTesting``

XCTest functions for capturing annotated screenshots during UI tests.

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

`HarnessKitScreenshotTesting` provides the **capture** side of the HarnessKit screenshot pipeline. It sets the device appearance, captures the screen, and attaches the result as a PNG to the test run with all `Screenshot` metadata embedded.

This library depends on `HarnessKitScreenshots` for the shared model types and requires `XCTest` — link it to your **UI test target only**.

### What It Does

- Sets `XCUIDevice.shared.appearance` from `Screenshot/appearance`
- Stamps `Screenshot/osVersion` from the running simulator
- Captures the screen (window-level on macOS with rounded corners, full-screen elsewhere)
- Encodes the `Screenshot` into the attachment filename via `Screenshot/screenshotName()`
- On macOS, rounds window corners at 35pt radius

### What It Does Not Do

- No image transformation (bezels, shadows, backgrounds) — that's `HarnessKitTransform`
- No navigation — that's `HarnessKitTesting`
- No model types — those are in `HarnessKitScreenshots`

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

- ``updateOrientation(config:)``
- ``setOrientation(to:)``

### Appearance

- ``resetTheme(to:)``
- ``currentTheme()``

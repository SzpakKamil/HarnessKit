# ``HarnessKitScreenshots``

Screenshot metadata, capture utilities, and configuration models for all Apple platforms.

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

`HarnessKitScreenshots` provides the data layer shared between UI test targets and the macOS transform tool. Use it in an XCUITest suite to capture annotated screenshots, and reference the same `Screenshot` and `ScreenshotConfig` types in `HarnessKitTransform` to produce finished App Store images.

The module has no external dependencies and compiles for iOS, iPadOS, macOS, tvOS, watchOS, and visionOS. XCTest-specific functions are guarded by `#if canImport(XCTest)` so the module stays linkable in non-test targets.

## Getting Started

@Links(visualStyle: detailedGrid) {
    - <doc:AboutHarnessKitScreenshots>
    - <doc:SetUpScreenshots>
}

## Topics

### Essentials

- <doc:AboutHarnessKitScreenshots>
- <doc:SetUpScreenshots>

### Screenshot Metadata

- ``Screenshot``
- ``ScreenshotConfig``
- ``VersionedBezel``

### Appearance and Orientation

- ``ScreenshotAppearance``
- ``ScreenOrientation``
- ``TargetOS``

### Layout and Cropping

- ``CropRect``
- ``FillMode``
- ``ScreenshotResolution``

### Capture

- ``captureScreenshot(screenshot:app:sleepSeconds:customActions:add:)``
- ``updateOrientation()``
- ``resetTheme(to:)``
- ``currentTheme()``

### Export

- ``ExportPath``

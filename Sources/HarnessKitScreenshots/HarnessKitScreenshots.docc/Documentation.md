# ``HarnessKitScreenshots``

Screenshot metadata and configuration models shared across the HarnessKit pipeline.

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

`HarnessKitScreenshots` is the **data layer** shared between UI test targets (via `HarnessKitScreenshotTesting`) and the macOS transform tool (via `HarnessKitTransform`). It defines ``Screenshot``, ``ScreenshotConfig``, and all supporting types.

This module contains **no XCTest code** — it is a pure model library with no external dependencies. It compiles for iOS, iPadOS, macOS, tvOS, watchOS, and visionOS. The capture functions (`captureScreenshot`, `updateOrientation`, `resetTheme`) live in `HarnessKitScreenshotTesting`.

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

### Background and Shadows

- ``ScreenshotBackground``
- ``ScreenshotShadow``
- ``DropShadow``
- ``ShapeShadow``

### Layout and Cropping

- ``CropRect``
- ``FillMode``
- ``ScreenshotResolution``

### Metadata Embedding

- ``ScreenshotMetadata``

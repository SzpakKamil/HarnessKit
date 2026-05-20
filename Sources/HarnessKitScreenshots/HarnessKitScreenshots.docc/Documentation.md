# ``HarnessKitScreenshots``

Screenshot metadata shared between the capture step and any consumer that reads the resulting PNGs.

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

`HarnessKitScreenshots` is the data layer of the screenshot pipeline. It defines ``Screenshot`` and its supporting enums. The library has no `XCTest` dependency and compiles on every Apple platform, so you can link it from either an app target or a UI test bundle.

The capture functions live next door in `HarnessKitScreenshotTesting`. This package only knows how to describe a screenshot and how to round-trip that description through a filename string or `Codable` JSON.

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

### Appearance, Orientation, and Platform

- ``ScreenshotAppearance``
- ``ScreenOrientation``
- ``TargetOS``

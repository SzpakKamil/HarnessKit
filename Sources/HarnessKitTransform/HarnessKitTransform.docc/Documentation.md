# ``HarnessKitTransform``

macOS image-processing pipeline that composites device bezels and produces App Store-ready screenshots.

@Metadata {
    @SupportedLanguage(swift)
    @Available(macOS, introduced: "11.0")
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

`HarnessKitTransform` takes a raw screenshot captured by `HarnessKitScreenshots` and transforms it into a finished image: rounding corners, applying a device bezel, adding a background color, cropping, and scaling to the target resolution. The pipeline is platform-specific — iOS, iPadOS, macOS, watchOS, tvOS, and visionOS each get dedicated compositing logic — and every step is an independent public function you can call directly to build custom pipelines.

The module is macOS-only. All image work uses `AppKit` (`NSImage`, `NSBitmapImageRep`).

## Getting Started

@Links(visualStyle: detailedGrid) {
    - <doc:AboutHarnessKitTransform>
    - <doc:SetUpTransform>
}

## Topics

### Essentials

- <doc:AboutHarnessKitTransform>
- <doc:SetUpTransform>

### Pipeline Entry Points

- ``transformScreenshot(image:screenshot:config:outputDirectory:)``
- ``processScreenshot(image:screenshot:config:)``

### Platform Processors

- ``processScreenshotIOS(image:config:screenshot:)``
- ``processScreenshotIPadOS(image:config:screenshot:)``
- ``processScreenshotMacOS(image:config:screenshot:)``
- ``processScreenshotWatchOS(image:config:screenshot:)``
- ``processScreenshotTVOS(image:config:screenshot:)``
- ``processScreenshotVisionOS(image:config:screenshot:)``

### Pipeline Steps

- ``prepareScreenshot(image:scaleMacOS:os:)``
- ``maskScreenshot(image:bezel:)``
- ``scaleToBezel(image:factor:)``
- ``placeBezel(image:bezel:verticalOffset:screenshotOnTop:)``
- ``applyOrientation(image:orientation:)``
- ``addBackgroundColor(image:color:)``
- ``cropImage(image:crop:)``
- ``adjustResolution(image:resolution:)``
- ``saveResults(image:name:to:)``

### Bezel Resolution

- ``resolveBezel(from:for:bezelType:)``
- ``BezelDescriptor``

### Bezel Catalogs

- ``PhoneBezel``
- ``PadBezel``
- ``WatchBezel``
- ``MacBezel``
- ``OtherBezel``

### Errors

- ``TransformError``

# ``HarnessKitTransform``

macOS image pipeline that composites device bezels, shadows, and backgrounds to produce App Store-ready screenshots.

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

`HarnessKitTransform` takes a raw screenshot and a `Screenshot` metadata value, then composites it with a device bezel frame, applies drop and shape shadows, fills the background, crops, and scales to the target resolution.

The module is **macOS-only** and uses `AppKit` (`NSImage`, `NSGraphicsContext`). All pipeline functions are `nonisolated` and safe to call from background threads via `Task.detached`.

### Module Structure

| Directory | Contents |
| :--- | :--- |
| **Pipeline/** | Compositing steps — `applyBezelPipeline`, `placeBezel`, `applyShadows`, `addBackground`, `composeCanvas`, `cropImage`, `adjustResolution` |
| **Platform/** | Per-OS entry points — `processScreenshotIOS`, `processScreenshotMacOS`, shared helpers |
| **Descriptors/** | Device catalogues — `DeviceDescriptor`, `MacDeviceDescriptor`, `WatchDeviceDescriptor` with bezel indexes |
| **Catalogue/** | R2 asset management — `HarnessKitCatalogue`, `ObjectCache`, `CatalogueStore`, `GenerationCache` |

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
- ``applyBezelPipeline(image:params:)``
- ``BezelPipelineParams``

### Multi-Device Composition

- ``composeCanvas(layers:canvasSize:background:crop:)``
- ``CanvasLayer``

### Pipeline Steps

- ``prepareScreenshot(image:os:)``
- ``maskScreenshot(image:cornerRadius:)``
- ``scaleToBezel(image:factor:)``
- ``placeBezel(image:bezel:verticalOffset:horizontalOffset:screenshotOnTop:scaleUpToFill:nativeScreenSize:)``
- ``applyOrientation(image:orientation:)``
- ``applyShadows(image:shadows:compositionSize:compositionCenter:)``
- ``addBackground(image:background:backgroundImageCache:)``
- ``cropImage(image:crop:)``
- ``adjustResolution(image:resolution:)``

### Device Descriptors

- ``DeviceDescriptor``
- ``MacDeviceDescriptor``
- ``WatchDeviceDescriptor``

### Remote Catalogue

- ``HarnessKitCatalogue``

### Output

- ``saveResults(image:screenshot:to:)``

### Errors

- ``TransformError``

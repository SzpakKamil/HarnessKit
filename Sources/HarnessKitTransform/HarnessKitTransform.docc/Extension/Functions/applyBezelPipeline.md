# ``HarnessKitTransform/applyBezelPipeline(image:params:)``

@Metadata {
    @SupportedLanguage(swift)
    @Available(macOS, introduced: "11.0")
    @DocumentationExtension(mergeBehavior: override)
}
@Options {
    @AutomaticSeeAlso(disabled)
    @AutomaticArticleSubheading(disabled)
}

Runs the full bezel pipeline on a screenshot image.

## Overview

Executes a five-step pipeline that transforms a raw screenshot into a finished, device-framed image:

1. **Compose device** — calls ``prepareScreenshot(image:os:)``, ``maskScreenshot(image:cornerRadius:)``, ``scaleToBezel(image:factor:)``, ``placeBezel(image:bezel:verticalOffset:horizontalOffset:screenshotOnTop:scaleUpToFill:nativeScreenSize:)``, and optionally ``applyOrientation(image:orientation:)`` to build the device composition at the bezel's native pixel resolution.
2. **Place on resolution canvas** — scales the composition to fit the target `ScreenshotResolution`, respecting ``BezelPipelineParams`` position and padding parameters.
3. **Apply shadows** — calls ``applyShadows(image:shadows:compositionSize:compositionCenter:)`` with shadow fractions relative to the fitted composition size.
4. **Apply background** — calls ``addBackground(image:background:backgroundImageCache:)`` behind all layers.
5. **Crop** — calls ``cropImage(image:crop:)`` if a `CropRect` is specified.

Each step checks for task cancellation and returns early when cancelled.

### Parameters

| Name | Type | Description |
| :--- | :--- | :--- |
| `image` | `NSImage` | The raw screenshot to process. |
| `params` | ``BezelPipelineParams`` | Configuration bundle containing bezel image, offsets, shadows, background, resolution, and all other pipeline settings. |

## See Also

- ``BezelPipelineParams``
- ``processScreenshot(image:screenshot:config:)``

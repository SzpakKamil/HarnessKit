# ``HarnessKitTransform/pixelSize(of:)``

@Metadata {
    @SupportedLanguage(swift)
    @Available(macOS, introduced: "11.0")
    @DocumentationExtension(mergeBehavior: override)
}
@Options {
    @AutomaticSeeAlso(disabled)
    @AutomaticArticleSubheading(disabled)
}

Returns the pixel dimensions of an image, ignoring DPI metadata.

## Overview

Queries the image's first representation for `pixelsWide` and `pixelsHigh`. This gives the true resolution-independent pixel count, unlike `NSImage.size` which is scaled by the display's DPI.

Falls back to `image.size` for lazily-drawn images (created with a drawing handler) whose representations report `-1` for pixel dimensions.

Use this function instead of `image.size` whenever you need the actual pixel count for layout math — for example, when computing aspect ratios or fitting a screenshot into a bezel frame.

### Parameters

| Name | Type | Description |
| :--- | :--- | :--- |
| `image` | `NSImage` | The image to measure. |

## See Also

- ``placeBezel(image:bezel:verticalOffset:horizontalOffset:screenshotOnTop:scaleUpToFill:nativeScreenSize:)``
- ``applyBezelPipeline(image:params:)``

# ``HarnessKitTransform/adjustResolution(image:resolution:)``

@Metadata {
    @SupportedLanguage(swift)
    @Available(macOS, introduced: "11.0")
    @DocumentationExtension(mergeBehavior: override)
}
@Options {
    @AutomaticSeeAlso(disabled)
    @AutomaticArticleSubheading(disabled)
}

Scales the image to fit the target resolution canvas.

## Overview

Aspect-fits the image into the dimensions defined by the `ScreenshotResolution`, centering the result on a transparent canvas. If the image already matches the target size, it is returned unchanged.

High-quality interpolation is used for downscaling and low-quality interpolation for drawing the fitted image, balancing sharpness with performance.

### Parameters

| Name | Type | Description |
| :--- | :--- | :--- |
| `image` | `NSImage` | The image to resize. |
| `resolution` | `ScreenshotResolution` | Target resolution defining the output canvas size. |

## See Also

- ``cropImage(image:crop:)``
- ``applyBezelPipeline(image:params:)``

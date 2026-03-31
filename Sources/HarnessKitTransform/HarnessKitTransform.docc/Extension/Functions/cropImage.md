# ``HarnessKitTransform/cropImage(image:crop:)``

@Metadata {
    @SupportedLanguage(swift)
    @Available(macOS, introduced: "11.0")
    @DocumentationExtension(mergeBehavior: override)
}

@Options {
    @AutomaticArticleSubheading(disabled)
}

Applies a normalized pan-and-zoom crop to an image.

## Overview

`cropImage` reads the normalized `CropRect` values, computes the source rectangle inside `image`, and stretches it back to fill the original canvas. The output is always the same dimensions as the input — cropping never changes the canvas size.

Pass the default `CropRect(x: 0, y: 0, width: 1, height: 1)` to leave the image unchanged.

## Parameters

| Name | Type | Description |
| :--- | :--- | :--- |
| `image` | `NSImage` | The image to crop. |
| `crop` | `CropRect` | Normalized pan-and-zoom descriptor from `Screenshot.crop`. |

## Returns

The cropped `NSImage` at the same size as the input.

## See Also

- ``CropRect``

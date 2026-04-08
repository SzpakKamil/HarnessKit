# ``HarnessKitTransform/cropImage(image:crop:)``

@Metadata {
    @SupportedLanguage(swift)
    @Available(macOS, introduced: "11.0")
    @DocumentationExtension(mergeBehavior: override)
}
@Options {
    @AutomaticSeeAlso(disabled)
    @AutomaticArticleSubheading(disabled)
}

Crops the image using a normalized zoom-and-pan rectangle.

## Overview

Applies a `CropRect` that defines a viewport into the image. The crop parameters work as a zoom and pan system centered on the image:

- `width` and `height` control zoom level (e.g. `2.0` = 2x zoom, `1.0` = no zoom).
- `x` and `y` pan the viewport within the zoomed image, where `0` is centered and `1` / `-1` shift to the edges.

An identity crop (`width: 1, height: 1, x: 0, y: 0`) returns the image unchanged. The output image retains the original canvas dimensions.

### Parameters

| Name | Type | Description |
| :--- | :--- | :--- |
| `image` | `NSImage` | The image to crop. |
| `crop` | `CropRect` | Normalized crop rectangle with zoom and pan values. |

## See Also

- ``addBackground(image:background:backgroundImageCache:)``
- ``adjustResolution(image:resolution:)``

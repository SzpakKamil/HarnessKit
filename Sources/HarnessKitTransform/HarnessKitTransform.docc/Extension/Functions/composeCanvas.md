# ``HarnessKitTransform/composeCanvas(layers:canvasSize:background:crop:)``

@Metadata {
    @SupportedLanguage(swift)
    @Available(macOS, introduced: "11.0")
    @DocumentationExtension(mergeBehavior: override)
}
@Options {
    @AutomaticSeeAlso(disabled)
    @AutomaticArticleSubheading(disabled)
}

Composites multiple device images onto a single canvas.

## Overview

Draws an array of ``CanvasLayer`` instances onto a canvas of the given size. Layers are drawn in array order — index 0 at the back, last index on top. Each layer's position and scale are relative to the canvas center.

After all layers are drawn, an optional `ScreenshotBackground` is applied behind the composite using ``addBackground(image:background:backgroundImageCache:)``, and an optional `CropRect` is applied using ``cropImage(image:crop:)``.

### Parameters

| Name | Type | Description |
| :--- | :--- | :--- |
| `layers` | `[CanvasLayer]` | Ordered list of layers to composite (bottom to top). |
| `canvasSize` | `NSSize` | Output canvas dimensions in pixels. |
| `background` | `ScreenshotBackground?` | Optional background fill drawn behind all layers. |
| `crop` | `CropRect?` | Optional crop rect applied to the final canvas. |

## See Also

- ``CanvasLayer``
- ``addBackground(image:background:backgroundImageCache:)``
- ``cropImage(image:crop:)``

# ``HarnessKitTransform/CanvasLayer/init(image:x:y:scale:)``

@Metadata {
    @SupportedLanguage(swift)
    @Available(macOS, introduced: "11.0")
    @DocumentationExtension(mergeBehavior: override)
}
@Options {
    @AutomaticSeeAlso(disabled)
    @AutomaticArticleSubheading(disabled)
}

Creates a canvas layer with a device image, position, and scale.

## Overview

All parameters except ``image`` have sensible defaults: centered position and natural size. Pass non-default values to arrange multiple devices side by side or at different scales within a single canvas.

### Parameters

| Name | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `image` | `NSImage` | — | The rendered device image, typically the output of ``applyBezelPipeline(image:params:)``. |
| `x` | `CGFloat` | `0` | Horizontal offset from center. `0` = center, `-1` = left edge, `1` = right edge. |
| `y` | `CGFloat` | `0` | Vertical offset from center. `0` = center, `1` = top edge, `-1` = bottom edge. |
| `scale` | `CGFloat` | `1.0` | Uniform scale applied before placement. `1.0` = natural size. |

## See Also

- ``CanvasLayer``
- ``composeCanvas(layers:canvasSize:background:crop:)``

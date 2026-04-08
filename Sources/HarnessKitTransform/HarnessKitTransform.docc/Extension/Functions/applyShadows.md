# ``HarnessKitTransform/applyShadows(image:shadows:compositionSize:compositionCenter:)``

@Metadata {
    @SupportedLanguage(swift)
    @Available(macOS, introduced: "11.0")
    @DocumentationExtension(mergeBehavior: override)
}
@Options {
    @AutomaticSeeAlso(disabled)
    @AutomaticArticleSubheading(disabled)
}

Applies an array of shadow effects to the canvas image.

## Overview

Supports two shadow types from `ScreenshotShadow`:

- **Shape shadows** — rounded rectangles drawn behind the image and optionally blurred with a Gaussian filter. Multiple shapes sharing the same blur radius are batched into a single Core Image pass for efficiency.
- **Drop shadows** — standard `NSShadow` effects applied to the device image itself, producing a shadow cast behind the composition.

All shadow fractions (blur, offset, size) are relative to `min(compositionSize.width, compositionSize.height)` or the composition dimensions, ensuring consistent appearance across resolutions. The canvas is never expanded — shadows clip to image bounds naturally.

### Parameters

| Name | Type | Description |
| :--- | :--- | :--- |
| `image` | `NSImage` | The canvas image containing the device composition. |
| `shadows` | `[ScreenshotShadow]` | Array of shadow descriptors to apply. |
| `compositionSize` | `NSSize` | The fitted device composition size on the canvas. |
| `compositionCenter` | `NSPoint` | The center point of the composition on the canvas. |

## See Also

- ``applyBezelPipeline(image:params:)``
- ``addBackground(image:background:backgroundImageCache:)``

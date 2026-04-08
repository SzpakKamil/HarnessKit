# ``HarnessKitScreenshots/ScreenshotBackground/image(name:directory:scale:offsetX:offsetY:)``

@Metadata {
    @SupportedLanguage(swift)
    @Available(iOS, introduced: "14.0")
    @Available(iPadOS, introduced: "14.0")
    @Available(macOS, introduced: "11.0")
    @Available(tvOS, introduced: "14.0")
    @Available(watchOS, introduced: "10.0")
    @Available(visionOS, introduced: "1.0")
    @DocumentationExtension(mergeBehavior: override)
}
@Options {
    @AutomaticSeeAlso(disabled)
    @AutomaticArticleSubheading(disabled)
}

Uses a named image file as the screenshot background with positioning control.

## Overview

The image is loaded from `directory` at render time and drawn behind the device bezel using aspect-fill. The `scale`, `offsetX`, and `offsetY` parameters control how the image is positioned within the canvas.

### Parameters

| Name | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `name` | `String` | — | Filename of the image (e.g. `"mountains.png"`). |
| `directory` | `String?` | `nil` | Full path to the directory containing the image. |
| `scale` | `Double` | `1.0` | Scale factor on top of aspect-fill. `1.0` = fill, `>1` = zoom in, `<1` = show more of the image. |
| `offsetX` | `Double` | `0` | Horizontal offset as fraction of canvas width. `0` = centered, positive = shift right. |
| `offsetY` | `Double` | `0` | Vertical offset as fraction of canvas height. `0` = centered, positive = shift up. |

### Examples

```swift
// Simple: just name and directory
.image(name: "gradient_bg.png", directory: "/path/to/backgrounds")

// With zoom and offset
.image(name: "photo.jpg", directory: "/path/to/bg", scale: 1.3, offsetX: 0.1, offsetY: -0.05)
```

## See Also
- ``HarnessKitScreenshots/ScreenshotBackground/solid(hex:)``
- ``HarnessKitScreenshots/ScreenshotBackground/gradient(startHex:endHex:angle:)``

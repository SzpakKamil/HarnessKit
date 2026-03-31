# ``HarnessKitTransform/addBackgroundColor(image:color:)``

@Metadata {
    @SupportedLanguage(swift)
    @Available(macOS, introduced: "11.0")
    @DocumentationExtension(mergeBehavior: override)
}

@Options {
    @AutomaticArticleSubheading(disabled)
}

Fills the canvas with a solid color behind the screenshot.

## Overview

`addBackgroundColor` draws `color` as a solid fill across the full canvas, then composites `image` on top using source-over blending. When `color` is `nil` the image is returned unchanged with a transparent background.

The color string is a six-digit hex value without a leading `#`:

```swift
addBackgroundColor(image: bezeled, color: "F2F2F7")  // light gray
addBackgroundColor(image: bezeled, color: "1C1C1E")  // dark gray
addBackgroundColor(image: bezeled, color: nil)        // transparent
```

## Parameters

| Name | Type | Description |
| :--- | :--- | :--- |
| `image` | `NSImage` | The image to place on top of the background. |
| `color` | `String?` | Six-digit hex color string (`"RRGGBB"`). `nil` returns the image unchanged. |

## Returns

The image composited over the solid background, or the original image if `color` is `nil`.

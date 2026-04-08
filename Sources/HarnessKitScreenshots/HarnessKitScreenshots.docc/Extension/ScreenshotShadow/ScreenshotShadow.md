# ``HarnessKitScreenshots/ScreenshotShadow``

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

A shadow effect applied to a device screenshot composition.

## Overview

`ScreenshotShadow` is an enum with two cases, each wrapping a distinct shadow style. Multiple shadows can be stacked per ``Screenshot`` — they are applied in array order, with shape shadows drawn behind the device and drop shadows composited on top via `NSShadow`.

All positional and dimensional values are expressed as **fractions of the composition's short side** (`min(width, height)`), making them resolution-independent. The same shadow parameters produce visually identical results regardless of the output resolution or bezel DPI.

### Shadow Types

| Case | Struct | Description |
| :--- | :--- | :--- |
| `.drop(...)` | ``DropShadow`` | A standard drop shadow that follows the device bezel's alpha silhouette. Controlled by blur radius and x/y offset. |
| `.shape(...)` | ``ShapeShadow`` | An independent rounded-rectangle shadow placed at a fixed position relative to the device center. Commonly used for contact shadow ellipses beneath the device. |

### Example

```swift
let screenshot = Screenshot(
    id: "home",
    appearance: .light,
    shadows: [
        .shape(ShapeShadow(opacity: 0.25, blur: 0.06, y: -1.1, width: 1.7, height: 0.025)),
        .drop(DropShadow(opacity: 0.4, blur: 0.02, offsetY: 0.01))
    ]
)
```

Shape shadows are rasterized, blurred via Core Image's Gaussian blur, and composited behind the device. Drop shadows use AppKit's `NSShadow` API applied to the graphics context before drawing the device image.

## Topics

### Cases

- ``drop(_:)``
- ``shape(_:)``

### Shadow Structs

- ``DropShadow``
- ``ShapeShadow``

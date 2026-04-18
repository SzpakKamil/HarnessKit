# ``HarnessKitScreenshots/ShapeShadow``

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

A standalone shape shadow drawn independently of the device bezel.

## Overview

`ShapeShadow` renders as a rounded rectangle at a fixed position relative to the device composition center. It is rasterized into an intermediate image, blurred with a Core Image Gaussian blur filter, and composited behind the device. This is commonly used for contact shadow ellipses that sit beneath the device, giving the composition a grounded, three-dimensional appearance.

All values are expressed as **fractions of the composition dimensions** for resolution-independent sizing.

### Default Values

The default initializer produces a thin, wide contact shadow positioned just below the device:

```swift
ShapeShadow()
// color: "000000", opacity: 0.3, blur: 0.06
// x: 0, y: -1.03, width: 1.1, height: 0.025, cornerRadius: 1
```

### Custom Shape Shadow

A wider, more visible shadow for marketing compositions:

```swift
ShapeShadow(
    color: "000000", opacity: 0.4, blur: 0.08,
    x: 0, y: -1.2,
    width: 2.0, height: 0.04,
    cornerRadius: 1
)
```

### Coordinate System

- **`x` / `y`**: Offset from the composition center as a fraction of half the composition width/height. `0` = centered, `1` = right/top edge, `-1` = left/bottom edge.
- **`width` / `height`**: Size as a fraction of the composition width/height.
- **`cornerRadius`**: Factor from 0 (sharp rectangle) to 1 (full ellipse). The actual pixel radius is `cornerRadius * min(width, height) / 2`.

## Properties

| Name | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `color` | `String` | `"000000"` | Shadow color as a hex string. |
| `opacity` | `Double` | `0.3` | Shadow opacity from 0 (invisible) to 1 (fully opaque). |
| `blur` | `Double` | `0.06` | Blur radius as a fraction of the composition short side. |
| `x` | `Double` | `0` | Horizontal center offset (0 = centered). |
| `y` | `Double` | `-1.03` | Vertical center offset. Negative values move the shadow below the device center. |
| `width` | `Double` | `1.1` | Width as a fraction of the composition width. |
| `height` | `Double` | `0.025` | Height as a fraction of the composition height. |
| `cornerRadius` | `Double` | `1` | Corner radius factor: 0 = rectangle, 1 = full ellipse. |

## See Also

- ``DropShadow``
- ``ScreenshotShadow``

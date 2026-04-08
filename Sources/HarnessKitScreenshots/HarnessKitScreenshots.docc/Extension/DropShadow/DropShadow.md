# ``HarnessKitScreenshots/DropShadow``

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

A standard drop shadow that follows the device bezel's alpha silhouette.

## Overview

`DropShadow` renders using AppKit's `NSShadow` API, which traces the alpha channel of the device composition. This produces a natural shadow that matches the exact outline of the bezel — including rounded corners and notch cutouts — without requiring a separate shape definition.

All values are expressed as **fractions of the composition's short side** for resolution-independent sizing.

### Default Values

The default initializer produces a subtle, slightly offset shadow suitable for most device previews:

```swift
DropShadow()
// color: "000000", opacity: 0.5, blur: 0.02, offsetX: 0, offsetY: 0.01
```

### Custom Drop Shadow

```swift
DropShadow(color: "1A1A2E", opacity: 0.6, blur: 0.03, offsetX: 0, offsetY: 0.015)
```

## Properties

| Name | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `color` | `String` | `"000000"` | Shadow color as a hex string. |
| `opacity` | `Double` | `0.5` | Shadow opacity from 0 (invisible) to 1 (fully opaque). |
| `blur` | `Double` | `0.02` | Blur radius as a fraction of the composition short side. |
| `offsetX` | `Double` | `0` | Horizontal offset as a fraction of the composition short side. |
| `offsetY` | `Double` | `0.01` | Vertical offset as a fraction of the composition short side. Positive values move the shadow downward. |

## See Also

- ``ShapeShadow``
- ``ScreenshotShadow``

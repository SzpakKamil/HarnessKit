# ``HarnessKitScreenshots/ScreenshotBackground``

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

The background fill drawn behind a device composition.

## Overview

`ScreenshotBackground` is stored on each ``Screenshot`` and applied by the transform pipeline after the device bezel and shadows are composited. If `nil`, the area behind the device is left transparent.

Three modes are available:

| Case | Description |
| :--- | :--- |
| `.solid(hex:)` | Fills the canvas with a single color from a hex string (e.g. `"FFFFFF"`). |
| `.gradient(startHex:endHex:angle:)` | Draws a two-stop linear gradient. `angle` in degrees: 0 = bottom→top, 90 = left→right. |
| `.image(name:directory:scale:offsetX:offsetY:)` | Loads a named image from a directory and draws it with aspect-fill, scale, and offset control. |

### Image Backgrounds

The `.image` case includes full positioning control:

```swift
.image(
    name: "mountains.png",
    directory: "/path/to/backgrounds",
    scale: 1.2,      // 1.0 = aspect-fill, >1 = zoom in
    offsetX: 0.1,    // fraction of canvas width (0 = centered)
    offsetY: -0.05   // fraction of canvas height (0 = centered)
)
```

All parameters except `name` have defaults (`directory: nil`, `scale: 1.0`, `offsetX: 0`, `offsetY: 0`), so simple usage is still clean:

```swift
.image(name: "gradient_bg.png", directory: "/Users/me/Backgrounds")
```

### Encoding

`ScreenshotBackground` conforms to `Codable`, `Hashable`, and `Sendable`. JSON uses a discriminated union:

```json
{ "solid": { "hex": "FF0000" } }
{ "gradient": { "startHex": "E0E7FF", "endHex": "FFFFFF", "angle": 180 } }
{ "image": { "name": "mountains.png", "directory": "/path/to/bg", "scale": 1.2, "offsetX": 0.1 } }
```

Fields with default values (`scale: 1.0`, `offsetX: 0`, `offsetY: 0`) are omitted from the JSON output. Old JSON without the new fields decodes with defaults.

## Topics

### Cases

- ``solid(hex:)``
- ``gradient(startHex:endHex:angle:)``
- ``image(name:directory:scale:offsetX:offsetY:)``

# ``HarnessKitScreenshots/ScreenshotMetadata``

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

Reads and writes ``Screenshot`` metadata embedded in PNG files.

## Overview

`ScreenshotMetadata` uses the PNG `tEXt` chunk's `Description` field (via `kCGImagePropertyPNGDictionary`) to store a JSON-encoded ``Screenshot`` struct inside the image file itself. The full ``Screenshot`` struct is JSON-serialized into the PNG's `tEXt` `Description` field, encoding all of the following fields:

- `id` — the screenshot identifier string.
- `appearance` — light or dark appearance mode.
- `os` — the target operating system.
- `orientation` — the screen orientation (optional).
- `crop` — the crop rectangle applied to the raw capture.
- `background` — the background fill (solid color, gradient, or image; optional).
- `shadows` — the array of drop and shape shadow effects.
- `addBezel` — whether a device bezel frame should be composited.
- `osVersion` — the OS version string captured at test time (optional).

This allows the transform pipeline to read a PNG and know exactly which device, appearance, OS version, shadows, and background to apply — without requiring a sidecar file. The encoding is lossless and round-trips correctly through `CGImageSource` and `CGImageDestination`.

### Encoding Metadata

Use ``pngProperties(for:)`` to create an ImageIO properties dictionary for a ``Screenshot``:

```swift
let screenshot = Screenshot(id: "home", appearance: .light)
let properties = ScreenshotMetadata.pngProperties(for: screenshot)
// Pass to CGImageDestinationAddImage(destination, cgImage, properties as CFDictionary)
```

### Decoding Metadata

Use ``screenshot(from:)`` to decode from an ImageIO properties dictionary, or ``read(from:)`` to decode directly from a file URL:

```swift
if let screenshot = ScreenshotMetadata.read(from: pngURL) {
    print(screenshot.id, screenshot.appearance)
}
```

### Writing a PNG with Metadata

``write(cgImage:screenshot:to:)`` combines image data and metadata into a single PNG file:

```swift
try ScreenshotMetadata.write(cgImage: renderedImage, screenshot: screenshot, to: outputURL)
```

## Methods

| Name | Description |
| :--- | :--- |
| ``pngProperties(for:)`` | Returns an ImageIO properties dictionary containing the JSON-encoded screenshot. |
| ``screenshot(from:)`` | Decodes a ``Screenshot`` from an ImageIO properties dictionary. |
| ``read(from:)`` | Reads ``Screenshot`` metadata from a PNG file on disk. |
| ``write(cgImage:screenshot:to:)`` | Writes a `CGImage` as a PNG file with embedded metadata. |

## See Also

- ``Screenshot``

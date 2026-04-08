# ``HarnessKitScreenshots/Screenshot``

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
}

Metadata describing a single screenshot in the automation pipeline.

## Overview

`Screenshot` carries everything the pipeline needs to both capture the screenshot in a UI test and later transform it into a polished App Store image. It holds:

| Property | Type | Purpose |
| :--- | :--- | :--- |
| ``id`` | `String` | Unique identifier (e.g. `"home-light"`) |
| ``appearance`` | ``ScreenshotAppearance`` | `.light` or `.dark` — sets device theme before capture |
| ``os`` | ``TargetOS`` | Platform this screenshot targets (`.iOS`, `.macOS`, etc.) |
| ``osVersion`` | `String?` | OS version string stamped by capture infrastructure (e.g. `"26.0"`) |
| ``orientation`` | ``ScreenOrientation`` | Optional forced orientation override |
| ``crop`` | ``CropRect`` | Crop/zoom applied to the final output |
| ``background`` | ``ScreenshotBackground`` | Background fill behind the device (solid, gradient, or image) |
| ``shadows`` | `[ScreenshotShadow]` | Shadow effects composited onto the device |
| ``addBezel`` | `Bool` | Whether to composite the device bezel frame |

**Capture phase** — `captureScreenshot` reads `appearance` to set the device theme, stamps `osVersion` from the running simulator, and derives the output filename from `screenshotName()`.

**Transform phase** — `processScreenshot` uses all properties to select the correct bezel, apply shadows and background, crop, and produce the final App Store image.

```swift
let screenshot = Screenshot(
    id: "home",
    appearance: .light,
    background: .gradient(startHex: "E0E7FF", endHex: "FFFFFF", angle: 180),
    shadows: [.drop(DropShadow(opacity: 0.4, blur: 0.02))],
    addBezel: true
)
```

## Two Serialization Formats

`Screenshot` is encoded in two different ways depending on context:

### 1. Filename String (XCTest Attachments)

`screenshotName()` encodes a subset of fields into a flat `key*value^key*value.png` string used as the XCTest attachment name. This format is human-readable and filesystem-safe:

```
id*home^os*iOS^orientation*nil^appearance*Light^crop*0.0,0.0,1.0,1.0^background*solid:F2F2F7^osVersion*26.0.png
```

**Fields in filename**: `id`, `os`, `orientation`, `appearance`, `crop` (x,y,w,h), `background` (type:value), `osVersion` (if set), `addBezel` (only if false).

**Not in filename**: `shadows` — too complex for a filename string.

Parse back with ``fromScreenshotName(_:)``.

### 2. PNG Metadata (Full JSON)

``ScreenshotMetadata`` embeds the **complete** `Screenshot` struct as JSON in the PNG file's `tEXt` `Description` chunk via `kCGImagePropertyPNGDictionary`. This includes **all fields**:

```json
{
  "id": "home",
  "appearance": "Light",
  "os": "iOS",
  "osVersion": "26.0",
  "orientation": null,
  "crop": { "x": 0, "y": 0, "width": 1, "height": 1 },
  "background": { "solid": { "hex": "F2F2F7" } },
  "shadows": [{ "drop": { "color": "000000", "opacity": 0.4, "blur": 0.02, "offsetX": 0, "offsetY": 0.01 } }],
  "addBezel": true
}
```

**All fields are included** — including `shadows`, which is the key difference from the filename format. Use ``ScreenshotMetadata/read(from:)`` to extract the full `Screenshot` from a PNG file.

## Topics

### Creating a Screenshot

- ``init(id:appearance:os:orientation:crop:backgroundHex:shadows:addBezel:)``
- ``init(id:appearance:os:orientation:crop:background:shadows:addBezel:)``

### Properties

- ``id``
- ``appearance``
- ``os``
- ``osVersion``
- ``orientation``
- ``crop``
- ``background``
- ``backgroundHex``
- ``shadows``
- ``addBezel``

### Modifiers

- ``withOSVersion(_:)``

### Serialization

- ``screenshotName()``
- ``prettyName()``
- ``fromScreenshotName(_:)``

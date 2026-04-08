# About HarnessKitScreenshots

@Metadata {
    @SupportedLanguage(swift)
    @TitleHeading("Getting Started")
    @Available(iOS, introduced: "14.0")
    @Available(iPadOS, introduced: "14.0")
    @Available(macOS, introduced: "11.0")
    @Available(tvOS, introduced: "14.0")
    @Available(watchOS, introduced: "10.0")
    @Available(visionOS, introduced: "1.0")
    @Available(swift, introduced: "5.9")
    @Available(Xcode, introduced: "15.0")
    @PageColor(orange)
}

@Options {
    @AutomaticSeeAlso(disabled)
}

Screenshot metadata and configuration types shared across the HarnessKit pipeline.

## Overview

`HarnessKitScreenshots` is the **data layer** of the screenshot pipeline. It defines the types that flow between the UI test target (via `HarnessKitScreenshotTesting`) and the macOS transform tool (via `HarnessKitTransform`). It contains **no XCTest code** — it is a pure model library that compiles on all Apple platforms.

### Where It Fits

| Library | Role | Depends On |
| :--- | :--- | :--- |
| **HarnessKitScreenshots** | Model types: ``Screenshot``, ``ScreenshotConfig``, ``VersionedBezel``, ``ScreenshotShadow``, ``ScreenshotBackground``, ``ScreenshotMetadata`` | — (standalone) |
| `HarnessKitScreenshotTesting` | XCTest capture: `captureScreenshot`, `updateOrientation`, `resetTheme` | HarnessKitScreenshots |
| `HarnessKitTransform` | macOS image pipeline: `processScreenshot`, `applyBezelPipeline`, `HarnessKitCatalogue` | HarnessKitScreenshots |

### Pipeline Flow

1. A UI test (using `HarnessKitScreenshotTesting`) creates a ``Screenshot`` value and calls `captureScreenshot(screenshot:app:add:)`.
2. The capture function sets the device appearance, captures the screen, and attaches a PNG. The attachment name encodes key metadata via ``Screenshot/screenshotName()``. The full ``Screenshot`` is also JSON-embedded inside the PNG via ``ScreenshotMetadata``.
3. The macOS transformer app reads the embedded metadata with ``ScreenshotMetadata/read(from:)`` to reconstruct the full ``Screenshot`` — including ``Screenshot/shadows``.
4. `HarnessKitTransform` uses all ``Screenshot`` properties to produce the final App Store image.

## The Screenshot Value

``Screenshot`` is the single source of truth for one captured frame. Every property feeds either the capture step or the transform step:

| Property | Capture | Transform |
| :--- | :--- | :--- |
| ``Screenshot/id`` | Output filename | — |
| ``Screenshot/appearance`` | Sets device theme | Picks macOS bezel art (light/dark) |
| ``Screenshot/os`` | — | Selects platform pipeline branch |
| ``Screenshot/osVersion`` | Stamped automatically | Picks versioned bezel via ``ScreenshotConfig/matchedBezel(for:)`` |
| ``Screenshot/orientation`` | Rotates simulator (iOS) | Rotates composed image |
| ``Screenshot/crop`` | — | Pan-and-zoom crop on final output |
| ``Screenshot/background`` | — | Canvas fill (solid, gradient, or image) |
| ``Screenshot/shadows`` | — | Drop and shape shadows on device |
| ``Screenshot/addBezel`` | — | Toggles bezel compositing |

```swift
import HarnessKitScreenshots

let screenshot = Screenshot(
    id: "home",
    appearance: .light,
    background: .gradient(startHex: "E0E7FF", endHex: "FFFFFF", angle: 180),
    shadows: [.drop(DropShadow(opacity: 0.4, blur: 0.02))],
    addBezel: true
)
```

## Two Serialization Formats

``Screenshot`` is encoded in two ways depending on context:

### Filename String

``Screenshot/screenshotName()`` produces a flat `key*value^key*value.png` string used as the XCTest attachment name. It encodes: `id`, `os`, `orientation`, `appearance`, `crop`, `background`, `osVersion`, and `addBezel`. It does **not** include `shadows` (too complex for a filename).

```
id*home^os*iOS^orientation*nil^appearance*Light^crop*0.0,0.0,1.0,1.0^background*solid:F2F2F7^osVersion*26.0.png
```

Parse back with ``Screenshot/fromScreenshotName(_:)``.

### PNG Metadata (Full JSON)

``ScreenshotMetadata`` embeds the **complete** ``Screenshot`` struct — including ``Screenshot/shadows`` — as JSON in the PNG file's `tEXt` `Description` chunk. This is the authoritative format used by the transform pipeline.

```json
{
  "id": "home",
  "appearance": "Light",
  "os": "iOS",
  "osVersion": "26.0",
  "background": { "gradient": { "startHex": "E0E7FF", "endHex": "FFFFFF", "angle": 180 } },
  "shadows": [{ "drop": { "color": "000000", "opacity": 0.4, "blur": 0.02, "offsetX": 0, "offsetY": 0.01 } }],
  "addBezel": true
}
```

## Versioned Bezels

Different OS versions ship on different hardware. ``ScreenshotConfig`` stores `[VersionedBezel]` arrays — one per platform — so the transform tool picks the right device art automatically:

```swift
var config = ScreenshotConfig.defaults
config.phoneBezel = [
    VersionedBezel(minVersion: "16.0", maxVersion: "26.0", deviceID: "iPhone16", color: "Black"),
    VersionedBezel(minVersion: "26.0", deviceID: "iPhone17", color: "Black")
]
```

A screenshot with `osVersion: "18.2"` picks `iPhone16`; one with `osVersion: "26.0"` picks `iPhone17`.

The config is owned by your project — load it from Application Support with ``ScreenshotConfig/load(from:)`` or build it programmatically from ``ScreenshotConfig/defaults``.

## Next Steps

- <doc:SetUpScreenshots>
- <doc:HarnessKitScreenshots>

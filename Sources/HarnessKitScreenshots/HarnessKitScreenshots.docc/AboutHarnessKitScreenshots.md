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

Share screenshot configuration and metadata between your UI test targets and the macOS transform tool.

## Overview

`HarnessKitScreenshots` sits at the center of the screenshot pipeline. It defines `Screenshot` — the value you create in a test to describe what to capture — and `ScreenshotConfig` — the JSON-backed config that tells the macOS transform tool which device bezel to use and at what resolution to export.

A typical run looks like this:

1. A UI test calls `captureScreenshot(screenshot:app:sleepSeconds:customActions:add:)` with a `Screenshot` value describing the screen being tested.
2. The function sets the device appearance, waits, and attaches a PNG to the test run. The attachment name encodes all screenshot metadata.
3. The macOS Tester app picks up those attachments, parses each name back into a `Screenshot` via `Screenshot.fromScreenshotName(_:)`, and passes them to `HarnessKitTransform` for processing.

## The Screenshot Value

`Screenshot` is the single source of truth for one captured frame. Every property feeds either the capture step or the transform step:

| Property | Capture | Transform |
| :--- | :--- | :--- |
| `id` | Output filename | — |
| `appearance` | Sets device theme | Picks macOS bezel art |
| `os` | — | Selects pipeline branch |
| `osVersion` | — | Picks versioned bezel |
| `orientation` | — | Rotates composed image |
| `crop` | — | Pan-and-zoom crop |
| `backgroundHex` | — | Canvas fill color |
| `addBezel` | — | Toggles bezel compositing |

```swift
import HarnessKitScreenshots

let screenshot = Screenshot(
    id: "home",
    appearance: .light,
    os: .iOS,
    osVersion: "18.2",
    backgroundHex: "F2F2F7"
)
```

## Versioned Bezels

Different OS versions ship on different hardware. `ScreenshotConfig` stores `[VersionedBezel]` arrays — one per platform — so the transform tool can pick the right device art automatically:

```swift
let config = ScreenshotConfig(
    phoneBezel: [
        VersionedBezel(minVersion: "16.0", maxVersion: "26.0", bezelID: "iPhone16Black"),
        VersionedBezel(minVersion: "26.0", bezelID: "iPhone17Black")
    ],
    phoneOrientation: .portrait,
    // ...
    resolution: .default
)
```

A screenshot with `osVersion: "18.2"` picks `iPhone16Black`; one with `osVersion: "26.0"` picks `iPhone17Black`.

Load the bundled defaults with `ScreenshotConfig.load()` or build the config programmatically and pass it directly to `HarnessKitTransform`.

## Next Steps

- <doc:SetUpScreenshots>
- <doc:HarnessKitScreenshots>

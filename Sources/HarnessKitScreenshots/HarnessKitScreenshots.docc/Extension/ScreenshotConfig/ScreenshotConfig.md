# ``HarnessKitScreenshots/ScreenshotConfig``

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

Per-platform screenshot configuration for the transform pipeline.

## Overview

`ScreenshotConfig` tells the transform pipeline which device bezel to use for each platform and what output resolution to target. Each platform stores a `[VersionedBezel]` array instead of a single bezel ID, so the correct hardware art is selected automatically based on `Screenshot.osVersion`.

The config is owned by the consumer project — not bundled inside HarnessKit. Load it from your app's Application Support directory or build it programmatically:

```swift
// Load from a file
let config = ScreenshotConfig.load(from: myConfigURL)

// Or start from defaults and override
var config = ScreenshotConfig.defaults
config.resolution = .full
config.phoneBezel = [
    VersionedBezel(minVersion: "16.0", deviceID: "iPhone16", color: "Black"),
    VersionedBezel(minVersion: "26.0", deviceID: "iPhone17", color: "Black")
]
```

## JSON Format

`ScreenshotConfig` is `Codable` and can be loaded from any JSON file. The consumer project decides where to store it.

```json
{
  "phoneBezel": [
    { "minVersion": "16.0", "deviceID": "iPhone16", "color": "Black" },
    { "minVersion": "26.0", "deviceID": "iPhone17", "color": "Black" }
  ],
  "phoneOrientation": "Portrait",
  "padBezel": [{ "minVersion": "17.0", "deviceID": "iPadAir11M4", "color": "Blue" }],
  "padOrientation": "Landscape",
  "watchBezel": [{ "minVersion": "11.0", "deviceID": "AppleWatchS1146mmAluminum", "color": "JetBlack", "band": "SportBandBlack" }],
  "macBezel": [{ "minVersion": "15.0", "deviceID": "MacbookPro16M4", "color": "Silver" }],
  "tvBezel": [{ "minVersion": "18.0", "deviceID": "AppleTVFrame", "color": "Default" }],
  "visionBezel": [],
  "resolution": "default"
}
```

## Topics

### Loading Config

- ``load(from:)``
- ``defaults``

### Per-Platform Bezels

- ``phoneBezel``
- ``padBezel``
- ``watchBezel``
- ``macBezel``
- ``tvBezel``
- ``visionBezel``

### Orientation

- ``phoneOrientation``
- ``padOrientation``

### Output

- ``resolution``

### Version-Aware Resolution

- ``matchedBezel(for:)``

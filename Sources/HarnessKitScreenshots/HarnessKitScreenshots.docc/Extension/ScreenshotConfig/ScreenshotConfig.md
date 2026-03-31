# ``HarnessKitScreenshots/ScreenshotConfig``

@Metadata {
    @SupportedLanguage(swift)
    @DocumentationExtension(mergeBehavior: override)
}

@Options {
    @AutomaticSeeAlso(disabled)
}

Per-platform screenshot configuration loaded from a JSON bundle resource.

## Overview

`ScreenshotConfig` tells the transform pipeline which device bezel to use for each platform and what output resolution to target. Each platform stores a `[VersionedBezel]` array instead of a single bezel ID, so the correct hardware art is selected automatically based on `Screenshot.osVersion`.

Load the bundled defaults with `ScreenshotConfig.load()`. Override any field before passing the config to the transform pipeline:

```swift
var config = await ScreenshotConfig.load()
config.resolution = .full
config.phoneBezel = [
    VersionedBezel(minVersion: "16.0", maxVersion: "26.0", bezelID: "iPhone16Black"),
    VersionedBezel(minVersion: "26.0", bezelID: "iPhone17Black")
]
```

## JSON Format

`ScreenshotConfig` decodes from `config.json` inside the module bundle. The file lives at `Sources/HarnessKitScreenshots/Resources/config.json`.

```json
{
  "phoneBezel": [
    { "minVersion": "16.0", "maxVersion": "26.0", "bezelID": "iPhone16Black" },
    { "minVersion": "26.0", "bezelID": "iPhone17Black" }
  ],
  "phoneOrientation": "Portrait",
  "padBezel": [{ "minVersion": "16.0", "bezelID": "iPadMiniA17ProStarlight" }],
  "padOrientation": "Landscape",
  "watchBezel": [{ "minVersion": "11.0", "bezelID": "AppleWatchS1146mmAluminumJetBlackSportBandBlack" }],
  "macBezel": [{ "minVersion": "15.0", "bezelID": "MacbookPro16M4Silver" }],
  "tvBezel": [{ "minVersion": "18.0", "bezelID": "AppleTVFrame" }],
  "resolution": "default"
}
```

## Topics

### Loading Config

- ``load()``
- ``defaults``

### Per-Platform Bezels

- ``phoneBezel``
- ``padBezel``
- ``watchBezel``
- ``macBezel``
- ``tvBezel``

### Orientation

- ``phoneOrientation``
- ``padOrientation``

### Output

- ``resolution``

### Version-Aware Resolution

- ``bezelID(for:)``

# ``HarnessKitScreenshots/ScreenshotConfig/init(phoneBezel:phoneOrientation:padBezel:padOrientation:watchBezel:macBezel:tvBezel:visionBezel:resolution:)``

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

Creates a screenshot configuration with explicit values for every platform.

## Overview

Use this initializer when you need full control over every platform's bezel selection, orientation, and output resolution. The `visionBezel` parameter defaults to an empty array, so you can omit it for most configurations.

For a quicker starting point, use ``ScreenshotConfig/defaults`` and override individual properties, or use ``ScreenshotConfig/load(from:)`` to decode a JSON file.

## Parameters

| Name | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `phoneBezel` | `[VersionedBezel]` | — | Versioned bezel entries for iPhone. The pipeline picks the first entry whose version range covers the screenshot's OS version. |
| `phoneOrientation` | ``ScreenOrientation`` | — | Default orientation for phone screenshots (`.portrait` or `.landscape`). Individual screenshots can override via ``Screenshot/orientation``. |
| `padBezel` | `[VersionedBezel]` | — | Versioned bezel entries for iPad. |
| `padOrientation` | ``ScreenOrientation`` | — | Default orientation for iPad screenshots. |
| `watchBezel` | `[VersionedBezel]` | — | Versioned bezel entries for Apple Watch. Each entry includes `color` and `band` to select the specific watch band image. |
| `macBezel` | `[VersionedBezel]` | — | Versioned bezel entries for Mac. Each entry includes `color` and `wallpaperType` to select the bezel variant. |
| `tvBezel` | `[VersionedBezel]` | — | Versioned bezel entries for Apple TV. |
| `visionBezel` | `[VersionedBezel]` | `[]` | Versioned bezel entries for Apple Vision Pro. Defaults to empty (no bezel compositing for visionOS). |
| `resolution` | ``ScreenshotResolution`` | — | Output resolution for transformed screenshots. Use `.full` for native resolution, `.default` for App Store standard, or `.custom(width:height:)` for a specific size. |

## Example

```swift
let config = ScreenshotConfig(
    phoneBezel: [
        VersionedBezel(minVersion: "16.0", maxVersion: "26.0", deviceID: "iPhone16", color: "Black"),
        VersionedBezel(minVersion: "26.0", deviceID: "iPhone17", color: "Black")
    ],
    phoneOrientation: .portrait,
    padBezel: [
        VersionedBezel(minVersion: "17.0", deviceID: "iPadAir11M4", color: "Blue")
    ],
    padOrientation: .landscape,
    watchBezel: [
        VersionedBezel(minVersion: "11.0", deviceID: "AppleWatchS1146mmAluminum", color: "JetBlack", band: "SportBandBlack")
    ],
    macBezel: [
        VersionedBezel(minVersion: "15.0", deviceID: "MacbookPro16M4", color: "Silver")
    ],
    tvBezel: [
        VersionedBezel(minVersion: "18.0", deviceID: "AppleTVFrame", color: "Default")
    ],
    resolution: .full
)
```

## See Also

- ``ScreenshotConfig/defaults``
- ``ScreenshotConfig/load(from:)``
- ``HarnessKitScreenshots/VersionedBezel``

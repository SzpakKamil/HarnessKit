# ``HarnessKitScreenshots/VersionedBezel``

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

A device bezel paired with the OS version range it applies to.

## Overview

`VersionedBezel` entries live inside ``ScreenshotConfig`` as arrays — one per platform. During transformation, ``ScreenshotConfig/matchedBezel(for:)`` finds the best entry whose `[minVersion, maxVersion)` range covers `Screenshot.osVersion` and uses its `deviceID` and `color` to load the correct bezel image.

This solves the problem of testers running different OS versions: an iOS 18 simulator must use an iPhone 16 bezel, while iOS 26 testers should get an iPhone 17 bezel.

```swift
let phoneBezel: [VersionedBezel] = [
    // iOS 16.0 up to (not including) 26.0 → iPhone 16 Black
    VersionedBezel(minVersion: "16.0", maxVersion: "26.0", deviceID: "iPhone16", color: "Black"),
    // iOS 26.0 and above → iPhone 17 Black
    VersionedBezel(minVersion: "26.0", deviceID: "iPhone17", color: "Black")
]
```

If no entry matches — or if `Screenshot.osVersion` is `nil` — the pipeline falls back to the last entry in the array.

### Watch Bezels

For watchOS, `VersionedBezel` also carries `band` to select the correct watch band image:

```swift
VersionedBezel(
    minVersion: "11.0",
    deviceID: "AppleWatchS1146mmAluminum",
    color: "JetBlack",
    band: "SportBandBlack"
)
```

### Mac Bezels

For macOS, `wallpaperType` selects the desktop wallpaper variant rendered inside the bezel:

```swift
VersionedBezel(
    minVersion: "15.0",
    deviceID: "MacbookPro16M4",
    color: "Silver",
    wallpaperType: "Default"
)
```

## Properties

| Name | Type | Description |
| :--- | :--- | :--- |
| `id` | `UUID` | Auto-generated unique identifier for `Identifiable` conformance. |
| `minVersion` | `String` | Minimum OS version (inclusive) this bezel applies to, e.g. `"16.0"`. |
| `maxVersion` | `String?` | Maximum OS version (exclusive). `nil` means no upper bound. |
| `deviceID` | `String` | The device descriptor ID used to resolve the bezel image, e.g. `"iPhone17"`. |
| `color` | `String` | The bezel color variant, e.g. `"Black"`, `"Silver"`. |
| `band` | `String` | The watch band name (watchOS only). Empty string for other platforms. |
| `wallpaperType` | `String` | The macOS wallpaper variant (macOS only). Defaults to `"Default"`. |

## Topics

### Properties

- ``id``
- ``minVersion``
- ``maxVersion``
- ``deviceID``
- ``color``
- ``band``
- ``wallpaperType``

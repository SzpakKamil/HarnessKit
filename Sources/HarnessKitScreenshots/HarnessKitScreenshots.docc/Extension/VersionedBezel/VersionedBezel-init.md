# ``HarnessKitScreenshots/VersionedBezel/init(id:minVersion:maxVersion:deviceID:color:band:wallpaperType:)``

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

Creates a versioned bezel entry with the specified version range and device details.

## Overview

Use this initializer to build ``VersionedBezel`` entries programmatically. Only `minVersion`, `deviceID`, and `color` are required for most platforms. The remaining parameters have sensible defaults.

## Parameters

| Name | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `id` | `UUID` | `UUID()` | Auto-generated unique identifier for `Identifiable` conformance. You rarely need to set this manually. |
| `minVersion` | `String` | — | Minimum OS version this bezel applies to (inclusive). Use `"major.minor"` format, e.g. `"16.0"`, `"26.0"`. |
| `maxVersion` | `String?` | `nil` | Maximum OS version (exclusive). `nil` means no upper bound — this bezel applies to all versions from `minVersion` onward. |
| `deviceID` | `String` | — | The device descriptor ID that resolves to a bezel image. Must match an `id` in the device catalogue (e.g. `"iPhone17"`, `"MacbookPro16M4"`, `"AppleWatchS1146mmAluminum"`). |
| `color` | `String` | — | The bezel color variant (e.g. `"Black"`, `"Silver"`, `"Default"`). Must match a color in the device descriptor's `colors` array. |
| `band` | `String` | `""` | The watch band name for watchOS bezels (e.g. `"SportBandBlack"`, `"MilaneseLoop"`). Ignored for non-watchOS devices. |
| `wallpaperType` | `String` | `"Default"` | The macOS desktop wallpaper variant rendered inside the bezel (e.g. `"Default"`, `"Custom"`). Ignored for non-macOS devices. |

## Examples

### iPhone (minimal)

```swift
VersionedBezel(minVersion: "26.0", deviceID: "iPhone17", color: "Black")
```

### iPhone (version range)

```swift
VersionedBezel(minVersion: "16.0", maxVersion: "26.0", deviceID: "iPhone16", color: "Black")
```

### Apple Watch (with band)

```swift
VersionedBezel(
    minVersion: "11.0",
    deviceID: "AppleWatchS1146mmAluminum",
    color: "JetBlack",
    band: "SportBandBlack"
)
```

### Mac (with wallpaper)

```swift
VersionedBezel(
    minVersion: "15.0",
    deviceID: "MacbookPro16M4",
    color: "Silver",
    wallpaperType: "Default"
)
```

## See Also

- ``HarnessKitScreenshots/VersionedBezel``
- ``HarnessKitScreenshots/ScreenshotConfig``

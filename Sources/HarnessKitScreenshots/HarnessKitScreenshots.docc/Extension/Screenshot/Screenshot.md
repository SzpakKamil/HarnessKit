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

A single screenshot, described as a value type the capture pipeline can move around.

## Overview

`Screenshot` is everything the pipeline needs to know about one capture. It is a `Sendable`, `Codable`, `Hashable` struct with six fields:

| Property | Type | Purpose |
| :--- | :--- | :--- |
| ``id`` | `String` | Stable identifier you choose, like `"home"` or `"settings-detail"`. |
| ``appearance`` | ``ScreenshotAppearance`` | Light or dark mode, applied to the device before capture. |
| ``os`` | ``TargetOS`` | The Apple platform this shot is for. Defaults to ``TargetOS/currentOS``. |
| ``orientation`` | ``ScreenOrientation``? | Optional rotation applied on iOS. |
| ``addBezel`` | `Bool` | Records intent for downstream bezel compositing. Defaults to `true`. |
| ``osVersion`` | `String?` | Stamped by `captureScreenshot` from the running simulator. |

You construct one in test code:

```swift
import HarnessKitScreenshots

let shot = Screenshot(
    id: "home",
    appearance: .light,
    os: .iOS,
    orientation: nil,
    addBezel: true
)
```

You never pass `osVersion` yourself. The capture function reads `UIDevice.current.systemVersion` (or the platform equivalent), normalizes it to a `major.0` string, and threads it through ``withOSVersion(_:)`` before naming the PNG.

## Filename Round-Trip

``screenshotName()`` produces a stable, parseable filename for the XCTest attachment:

```
id*home^os*iOS^orientation*nil^appearance*Light^osVersion*26.0.png
```

The format uses `key*value` pairs joined by `^`. Keys are `id`, `os`, `orientation`, `appearance`, then `osVersion` and `addBezel` when they carry non-default values. ``fromScreenshotName(_:)`` reverses the operation and returns `nil` when the string is missing `id`, `os`, or `appearance`.

``prettyName()`` returns a friendlier label for use in logs or test reports.

## Codable

`Screenshot` conforms to `Codable` directly. Encode it through `JSONEncoder` if you want to ship the full value through any channel that prefers JSON over a flat filename string.

```swift
let json = try JSONEncoder().encode(shot)
```

The encoder and decoder go through every property, so the JSON form round-trips without loss.

## Topics

### Creating a Screenshot

- ``init(id:appearance:os:orientation:addBezel:)``

### Properties

- ``id``
- ``appearance``
- ``os``
- ``orientation``
- ``addBezel``
- ``osVersion``

### Modifiers

- ``withOSVersion(_:)``

### Serialization

- ``screenshotName()``
- ``prettyName()``
- ``fromScreenshotName(_:)``

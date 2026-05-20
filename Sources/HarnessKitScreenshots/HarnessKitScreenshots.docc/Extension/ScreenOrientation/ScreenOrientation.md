# ``HarnessKitScreenshots/ScreenOrientation``

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

The physical orientation of the device when a screenshot is captured.

## Overview

`ScreenOrientation` is a two-case `String`-backed enum: `portrait` and `landscape`. You assign it to ``Screenshot/orientation`` to force a rotation on iOS, or pass it directly to `updateOrientation(phone:pad:)` and `setOrientation(to:)` in `HarnessKitScreenshotTesting`.

On iOS, ``uiKitValue`` maps each case to a `UIDeviceOrientation`. `portrait` becomes `.portrait`. `landscape` becomes `.landscapeLeft`. The capture and orientation helpers read this property to drive `XCUIDevice.shared.orientation`. On every other platform the enum is still constructible, but its rotation effect is a no-op.

```swift
let landscape = Screenshot(
    id: "home-landscape",
    appearance: .light,
    os: .iPadOS,
    orientation: .landscape
)
```

The static factories ``orientation(from:)`` and ``orientation(fromSize:)`` recover a value from a stored name string or from a `CGSize` whose aspect ratio implies the rotation.

## Topics

### Cases

- ``portrait``
- ``landscape``

### Properties

- ``name``
- ``uiKitValue``

### Factories

- ``orientation(from:)``
- ``orientation(fromSize:)``

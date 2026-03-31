# ``HarnessKitScreenshots/ScreenOrientation``

@Metadata {
    @SupportedLanguage(swift)
    @DocumentationExtension(mergeBehavior: override)
}

@Options {
    @AutomaticSeeAlso(disabled)
}

The physical orientation of the device screen when a screenshot was captured.

## Overview

`ScreenOrientation` appears in two contexts:

**Capture** — `updateOrientation()` reads `ScreenshotConfig.phoneOrientation` and `ScreenshotConfig.padOrientation` to rotate the simulator before capture. On iOS, `.landscape` maps to `UIDeviceOrientation.landscapeLeft`.

**Transform** — `applyOrientation(image:orientation:)` rotates the composed image 90° clockwise when the value is `.landscape`.

Set `orientation` on a `Screenshot` to override the config default for a specific capture:

```swift
let landscapeShot = Screenshot(
    id: "home-landscape",
    appearance: .light,
    os: .iPadOS,
    orientation: .landscape
)
```

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

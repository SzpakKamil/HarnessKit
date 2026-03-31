# ``HarnessKitScreenshots/Screenshot``

@Metadata {
    @SupportedLanguage(swift)
    @DocumentationExtension(mergeBehavior: override)
}

@Options {
    @AutomaticSeeAlso(disabled)
}

Metadata describing a single screenshot in the automation pipeline.

## Overview

`Screenshot` carries everything the pipeline needs to both capture the screenshot in a UI test and later transform it into a polished App Store image.

**Capture phase** — `captureScreenshot` reads `appearance` to set the device theme and derives the output filename from `screenshotName()`.

**Transform phase** — `processScreenshot` uses `os`, `osVersion`, `appearance`, `orientation`, `crop`, `backgroundHex`, and `addBezel` to composite the final image.

```swift
let screenshot = Screenshot(
    id: "home",
    appearance: .light,
    os: .iOS,
    osVersion: "18.2",
    crop: CropRect(x: 0, y: 0.1, width: 1.05, height: 1.05),
    backgroundHex: "F2F2F7",
    addBezel: true
)
```

## Serialization

`Screenshot` is `Codable` for JSON storage. It also implements a stable flat-string format used as XCTest attachment names:

```
id*home^os*iOS^orientation*nil^appearance*Light^crop*0.0,0.0,1.0,1.0^backgroundHex*F2F2F7^osVersion*18.2.png
```

Parse that string back with `Screenshot.fromScreenshotName(_:)`. The transform tool uses this round-trip to reconstruct `Screenshot` values from the attachments exported from a test run.

## Topics

### Creating a Screenshot

- ``init(id:appearance:os:orientation:crop:backgroundHex:addBezel:osVersion:)``

### Properties

- ``id``
- ``appearance``
- ``os``
- ``osVersion``
- ``orientation``
- ``crop``
- ``backgroundHex``
- ``addBezel``

### Serialization

- ``screenshotName()``
- ``prettyName()``
- ``fromScreenshotName(_:)``

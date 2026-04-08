# ``HarnessKitScreenshots/ScreenshotAppearance``

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

The UI color scheme applied before a screenshot was captured.

## Overview

Set `appearance` on a `Screenshot` to encode which color scheme the test applied. The capture function uses it to call `XCUIDevice.shared.appearance` before taking the screenshot, and the transform pipeline uses it to select the correct macOS bezel art — macOS bezels ship as separate PNGs for light and dark.

```swift
let screenshots: [Screenshot] = [
    Screenshot(id: "home", appearance: .light, os: .iOS),
    Screenshot(id: "home", appearance: .dark,  os: .iOS)
]
```

## Topics

### Cases

- ``light``
- ``dark``

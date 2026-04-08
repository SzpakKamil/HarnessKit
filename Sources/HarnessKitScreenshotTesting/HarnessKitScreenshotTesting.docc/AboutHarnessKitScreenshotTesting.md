# About HarnessKitScreenshotTesting

@Metadata {
    @SupportedLanguage(swift)
    @TitleHeading("Getting Started")
    @Available(iOS, introduced: "14.0")
    @Available(iPadOS, introduced: "14.0")
    @Available(macOS, introduced: "11.0")
    @Available(tvOS, introduced: "14.0")
    @Available(watchOS, introduced: "10.0")
    @Available(visionOS, introduced: "1.0")
    @Available(swift, introduced: "5.9")
    @Available(Xcode, introduced: "15.0")
    @PageColor(orange)
}

@Options {
    @AutomaticSeeAlso(disabled)
}

Capture annotated screenshots in UI tests with one function call.

## Overview

`HarnessKitScreenshotTesting` is the **capture** side of the HarnessKit screenshot pipeline. It provides XCTest functions that set the device appearance, capture the screen, and attach the result as a metadata-rich PNG to the test run.

This library depends on `HarnessKitScreenshots` for the shared model types (`Screenshot`, `ScreenshotConfig`, etc.) and requires `XCTest` — link it to your **UI test target only**.

### Where It Fits

| Step | Library | What Happens |
| :--- | :--- | :--- |
| 1. Define | `HarnessKitScreenshots` | Create `Screenshot` values describing each frame |
| **2. Capture** | **`HarnessKitScreenshotTesting`** | **Set appearance, capture screen, attach PNG** |
| 3. Transform | `HarnessKitTransform` | Composite bezels, shadows, backgrounds on macOS |

### What Gets Captured

Each call to ``captureScreenshot(screenshot:app:sleepSeconds:customActions:add:)`` produces a PNG attachment with:

- **Filename**: `Screenshot/screenshotName()` — a flat `key*value^key*value.png` string encoding `id`, `os`, `appearance`, `crop`, `background`, `osVersion`, and `addBezel`
- **OS version**: Stamped automatically from the running simulator as `major.0`
- **macOS**: Window captured with 35pt rounded corners
- **watchOS**: Dark-mode screenshots are skipped (appearance switching unsupported)

### Five Functions

| Function | Purpose |
| :--- | :--- |
| ``captureScreenshot(screenshot:app:sleepSeconds:customActions:add:)`` | Capture and attach a screenshot |
| ``updateOrientation(config:)`` | Set simulator orientation from config (iOS only) |
| ``setOrientation(to:)`` | Set simulator to a specific orientation (iOS only) |
| ``resetTheme(to:)`` | Switch device appearance mid-test |
| ``currentTheme()`` | Read the current device appearance |

### Example

```swift
import XCTest
import HarnessKitScreenshotTesting

final class HomeTests: XCTestCase {
    override func setUp() {
        super.setUp()
        updateOrientation()
    }

    func testHomeScreen() {
        let app = XCUIApplication()
        app.launch()

        let defaultTheme = currentTheme()

        captureScreenshot(
            screenshot: Screenshot(id: "home", appearance: .light),
            app: app,
            add: add
        )

        captureScreenshot(
            screenshot: Screenshot(id: "home", appearance: .dark),
            app: app,
            add: add
        )

        resetTheme(to: defaultTheme)
    }
}
```

## Next Steps

- <doc:SetUpScreenshotTesting>
- <doc:HarnessKitScreenshotTesting>

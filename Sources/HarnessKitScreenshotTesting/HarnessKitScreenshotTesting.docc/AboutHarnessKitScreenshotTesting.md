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

`HarnessKitScreenshotTesting` is the capture side of the screenshot pipeline. Five XCTest functions set device appearance, rotate the iOS simulator, capture the screen, and attach the result to the test run with a parseable filename.

The library depends on `HarnessKitScreenshots` for the `Screenshot` model type and imports `XCTest`. Link it to your UI test target only.

### What Gets Captured

A call to ``captureScreenshot(screenshot:app:sleepSeconds:customActions:add:)`` produces a PNG attachment:

- The filename comes from `Screenshot.screenshotName()`. It encodes `id`, `os`, `orientation`, `appearance`, and, when present, `osVersion` and `addBezel`.
- `Screenshot.osVersion` is stamped from the simulator as a `major.0` string.
- On macOS the capture is the app window, clipped to a 35-point corner radius.
- On watchOS, dark-mode captures are skipped because watchOS does not expose appearance switching.

### Five Functions

| Function | Purpose |
| :--- | :--- |
| ``captureScreenshot(screenshot:app:sleepSeconds:customActions:add:)`` | Set appearance, capture screen, attach PNG. |
| ``updateOrientation(phone:pad:)`` | Pick a phone or iPad orientation from the running idiom. iOS only. |
| ``setOrientation(to:)`` | Force a specific orientation. iOS only. |
| ``resetTheme(to:)`` | Switch the device appearance mid-test. |
| ``currentTheme()`` | Read the current device appearance. |

### Example

```swift
import XCTest
import HarnessKitScreenshots
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

`updateOrientation()` reads the running idiom: phones go portrait, iPads go landscape unless you override the defaults. `captureScreenshot` waits two seconds after each appearance change by default, then writes the PNG with the encoded filename.

## Next Steps

- <doc:SetUpScreenshotTesting>
- <doc:HarnessKitScreenshotTesting>

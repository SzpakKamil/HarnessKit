# ``HarnessKitScreenshotTesting/captureScreenshot(screenshot:app:sleepSeconds:customActions:add:)``

Captures one frame during a UI test and attaches it with a metadata-encoded filename.

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

## Overview

`captureScreenshot` is the primary entry point of the capture pipeline. Call it from inside an `XCTestCase` method and the function handles every step: stamp the OS version, set the device appearance, capture the screen, attach the PNG.

### Capture Flow

1. Reads the running simulator's version and writes it back through `Screenshot.withOSVersion(_:)` as a `major.0` string.
2. On iOS, applies `Screenshot.orientation` if you set one.
3. Sets `XCUIDevice.shared.appearance` to match `Screenshot.appearance`. Skipped on watchOS and visionOS, which do not support appearance switching.
4. Sleeps for `sleepSeconds` (default `2`) so the UI can settle.
5. Runs `customActions` for any extra setup.
6. Captures the screen. macOS captures the app window and rounds the corners at 35 points. watchOS captures only when appearance is not `.dark`. Every other platform calls `XCUIScreen.main.screenshot()`.
7. Attaches the PNG with `Screenshot.screenshotName()` as the filename.

### Example

```swift
import XCTest
import HarnessKitScreenshots
import HarnessKitScreenshotTesting

final class HomeTests: XCTestCase {
    func testHomeScreen() {
        let app = XCUIApplication()
        app.launch()

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
    }
}
```

### Custom Actions

Pass a `customActions` closure when you need extra setup between the appearance change and the capture. The closure runs after the sleep, so any animations triggered by your appearance change have already finished:

```swift
captureScreenshot(
    screenshot: Screenshot(id: "detail", appearance: .light),
    app: app,
    sleepSeconds: 3,
    customActions: { app.buttons["Show Detail"].tap() },
    add: add
)
```

## Parameters

| Name | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `screenshot` | `Screenshot` | required | Metadata describing the frame to capture. |
| `app` | `XCUIApplication` | required | The running application under test. |
| `sleepSeconds` | `UInt32` | `2` | Seconds to wait after setting appearance before capturing. |
| `customActions` | `() -> Void` | `{ }` | Extra setup to run before the capture. |
| `add` | `(XCTAttachment) -> Void` | required | Closure that attaches the PNG to the test, typically `self.add`. |

## See Also

- ``updateOrientation(phone:pad:)``
- ``resetTheme(to:)``

# ``HarnessKitScreenshotTesting/captureScreenshot(screenshot:app:sleepSeconds:customActions:add:)``

Captures a screenshot during a UI test and attaches it with metadata-encoded name.

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

This is the primary entry point for screenshot capture. Call it inside an `XCTestCase` method to capture a single frame and attach it to the test run.

### Capture Flow

1. Stamps `Screenshot/osVersion` from the running device (`major.0` format).
2. On iOS, applies `Screenshot/orientation` if set.
3. Sets `XCUIDevice.shared.appearance` to match `Screenshot/appearance` (skipped on watchOS and visionOS).
4. Sleeps for `sleepSeconds` (default 2) to let the UI settle.
5. Runs `customActions` closure for any additional setup.
6. Captures the screen:
   - **macOS**: Captures the app window with 35pt rounded corners.
   - **watchOS**: Captures only if appearance is not `.dark` (watchOS does not support appearance switching).
   - **All others**: Full-screen capture via `XCUIScreen.main.screenshot()`.
7. Attaches the PNG to the test with `Screenshot/screenshotName()` as the attachment name.

### Example

```swift
import XCTest
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

Pass a `customActions` closure to perform setup before capture — for example, tapping a button or scrolling to a specific position:

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
| `screenshot` | `Screenshot` | — | Metadata describing the frame to capture. |
| `app` | `XCUIApplication` | — | The running application under test. |
| `sleepSeconds` | `UInt32` | `2` | Seconds to wait after setting appearance before capturing. |
| `customActions` | `() -> Void` | `{ }` | Additional setup to run before capturing. |
| `add` | `(XCTAttachment) -> Void` | — | Closure that attaches the result to the test (typically `self.add`). |

## See Also

- ``updateOrientation(config:)``
- ``resetTheme(to:)``

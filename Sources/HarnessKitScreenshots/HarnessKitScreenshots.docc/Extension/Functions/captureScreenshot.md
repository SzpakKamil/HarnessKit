# ``HarnessKitScreenshots/captureScreenshot(screenshot:app:sleepSeconds:customActions:add:)``

@Metadata {
    @SupportedLanguage(swift)
    @DocumentationExtension(mergeBehavior: override)
}

@Options {
    @AutomaticArticleSubheading(disabled)
}

Captures a screenshot during a UI test and attaches it with a metadata-encoded name.

## Overview

Call this function inside an `XCTestCase` to capture and attach a screenshot. The function:

1. Sets `XCUIDevice.shared.appearance` to the value from `screenshot.appearance` (skipped on visionOS and watchOS).
2. Sleeps for `sleepSeconds` to let the UI settle.
3. Runs `customActions` if provided.
4. Captures the screen (or the front window on macOS, with rounded corners).
5. Attaches the PNG to the test run using `screenshot.screenshotName()` as the attachment name.

The attachment name encodes all metadata, so the macOS Tester app can reconstruct the full `Screenshot` value from it later via `Screenshot.fromScreenshotName(_:)`.

### macOS behavior

On macOS the function captures `app.windows.firstMatch` and applies a 35-point corner radius. If the window does not exist, it falls back to `XCUIScreen.main.screenshot()`.

### watchOS behavior

On watchOS only `.light` screenshots are captured. Dark-appearance screenshots are skipped because the watch simulator does not support forced dark mode.

## Parameters

| Name | Type | Description |
| :--- | :--- | :--- |
| `screenshot` | `Screenshot` | Metadata describing this screenshot. |
| `app` | `XCUIApplication` | The running app under test. |
| `sleepSeconds` | `UInt32` | Seconds to wait after applying the appearance. Default: `2`. |
| `customActions` | `() -> Void` | Optional setup closure to run before capture. Default: no-op. |
| `add` | `(XCTAttachment) -> Void` | The test's `add(_:)` method, used to attach the result. |

## Example

```swift
final class ScreenshotTests: XCTestCase {
    func testHomeScreen() {
        let app = XCUIApplication()
        app.launch()

        let screenshot = Screenshot(
            id: "home",
            appearance: .light,
            os: .iOS,
            osVersion: "18.2"
        )

        captureScreenshot(screenshot: screenshot, app: app, add: add)
    }
}
```

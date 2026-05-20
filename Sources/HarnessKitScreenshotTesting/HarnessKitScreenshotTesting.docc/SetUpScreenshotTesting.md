# Set Up Screenshot Testing

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

Add `HarnessKitScreenshotTesting` to your UI test target and start capturing screenshots.

## Overview

`HarnessKitScreenshotTesting` requires `XCTest`, so it belongs in a UI test target. Do not add it to your app target. The link step will fail, and even if it did not, you would ship the `XCTest` framework with your production binary.

## Adding to Your Project

1. In Xcode, choose **File > Add Packages...**.
2. Paste the HarnessKit repository URL and click **Add Package**.
3. Assign `HarnessKitScreenshotTesting` to your UI test target.

`HarnessKitScreenshots` comes along transitively. You do not need to add it separately unless your app target also constructs `Screenshot` values.

## Import

```swift
import XCTest
import HarnessKitScreenshots
import HarnessKitScreenshotTesting
```

This gives you all five functions: ``captureScreenshot(screenshot:app:sleepSeconds:customActions:add:)``, ``updateOrientation(phone:pad:)``, ``setOrientation(to:)``, ``resetTheme(to:)``, and ``currentTheme()``.

## Basic Usage

### 1. Set Orientation, iOS Only

Call ``updateOrientation(phone:pad:)`` in `setUp()` to rotate the simulator. The defaults are portrait on iPhone and landscape on iPad:

```swift
override func setUp() {
    super.setUp()
    updateOrientation()
}
```

Override the defaults for a specific test:

```swift
updateOrientation(phone: .landscape, pad: .landscape)
```

To force a specific orientation regardless of idiom, use ``setOrientation(to:)``:

```swift
setOrientation(to: .portrait)
```

### 2. Capture Screenshots

Create `Screenshot` values and pass them to ``captureScreenshot(screenshot:app:sleepSeconds:customActions:add:)``:

```swift
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
```

### 3. Manage Appearance

``currentTheme()`` reads the current `XCUIDevice.Appearance`. ``resetTheme(to:)`` writes it back. Save and restore around a test that changes themes:

```swift
let before = currentTheme()
// capture screenshots in light and dark
resetTheme(to: before)
```

## Platform Differences

| Platform | Appearance | Orientation | Capture Method |
| :--- | :--- | :--- | :--- |
| iOS, iPadOS | `XCUIDevice.shared.appearance` | `XCUIDevice.shared.orientation` | `XCUIScreen.main.screenshot()` |
| macOS | `XCUIDevice.shared.appearance` | not supported | App window, 35pt rounded corners |
| tvOS | `XCUIDevice.shared.appearance` | not supported | `XCUIScreen.main.screenshot()` |
| watchOS | not supported | not supported | `XCUIScreen.main.screenshot()`, light only |
| visionOS | not supported | not supported | `XCUIScreen.main.screenshot()` |

## Troubleshooting

- **`captureScreenshot` is unresolved.** You imported `HarnessKitScreenshots` instead of `HarnessKitScreenshotTesting`. Add the second import.
- **Dark captures are missing on watchOS.** Expected. The capture skips dark mode because watchOS cannot switch appearance through `XCUIDevice`.
- **`updateOrientation` does nothing on macOS or tvOS.** Expected. The function only runs on iOS.
- **`resetTheme` and `currentTheme` are unavailable.** They require macOS 12, iOS 15, tvOS 15, visionOS 1, or watchOS 10. Bump your deployment target or guard the calls.

## Next Steps

- <doc:HarnessKitScreenshotTesting>
- <doc:AboutHarnessKitScreenshotTesting>

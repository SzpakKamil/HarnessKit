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

`HarnessKitScreenshotTesting` requires `XCTest` and must be linked to a **UI test target**. Do not add it to your main app target.

## Adding to Your Project

1. In Xcode, select **File > Add Packages...**.
2. Enter the HarnessKit repository URL and click **Add Package**.
3. Assign `HarnessKitScreenshotTesting` to your **UI test target**.

`HarnessKitScreenshots` is imported transitively — you do not need to add it separately to the test target.

> Important: Do not link `HarnessKitScreenshotTesting` to your app target. It imports `XCTest`, which cannot link into a production binary.

## Import

```swift
import XCTest
import HarnessKitScreenshotTesting
```

This gives you access to all five functions: ``captureScreenshot(screenshot:app:sleepSeconds:customActions:add:)``, ``updateOrientation(config:)``, ``setOrientation(to:)``, ``resetTheme(to:)``, and ``currentTheme()``.

## Basic Usage

### 1. Set Orientation (iOS only)

Call ``updateOrientation(config:)`` in `setUp()` to rotate the simulator. Pass a config loaded from your project, or use the default:

```swift
override func setUp() {
    super.setUp()
    updateOrientation()
}
```

### 2. Capture Screenshots

Create ``Screenshot`` values and pass them to ``captureScreenshot(screenshot:app:sleepSeconds:customActions:add:)``:

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

Use ``currentTheme()`` and ``resetTheme(to:)`` to save and restore the appearance around a test:

```swift
let before = currentTheme()
// ... capture screenshots with various appearances ...
resetTheme(to: before)
```

## Platform Differences

| Platform | Appearance | Orientation | Capture Method |
| :--- | :--- | :--- | :--- |
| iOS / iPadOS | `XCUIDevice.shared.appearance` | `XCUIDevice.shared.orientation` | `XCUIScreen.main.screenshot()` |
| macOS | `XCUIDevice.shared.appearance` | — | Window capture with 35pt rounded corners |
| tvOS | `XCUIDevice.shared.appearance` | — | `XCUIScreen.main.screenshot()` |
| watchOS | Skipped (unsupported) | — | `XCUIScreen.main.screenshot()` (light only) |
| visionOS | Skipped (unsupported) | — | `XCUIScreen.main.screenshot()` |

## Troubleshooting

- **`captureScreenshot` not found**: Confirm you imported `HarnessKitScreenshotTesting`, not `HarnessKitScreenshots`.
- **Dark screenshots missing on watchOS**: Expected — watchOS does not support appearance switching. Dark-mode captures are automatically skipped.
- **Orientation not applied**: ``updateOrientation(config:)`` only works on iOS. On other platforms it is a no-op.
- **Appearance not applied**: ``resetTheme(to:)`` requires macOS 12.0+ / iOS 15.0+ / tvOS 15.0+. On older OS versions the function is unavailable.

## Next Steps

- <doc:HarnessKitScreenshotTesting>
- <doc:AboutHarnessKitScreenshotTesting>

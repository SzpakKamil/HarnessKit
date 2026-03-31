# Set Up Screenshots

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

Add `HarnessKitScreenshots` to your UI test target and capture annotated screenshots in one function call.

## Overview

`HarnessKitScreenshots` ships as a library product inside the `HarnessKit` package. Link it to your XCUITest target to access `captureScreenshot` and the `Screenshot` / `ScreenshotConfig` types.

## Adding HarnessKitScreenshots

1. In Xcode, select **File > Add Packages...**.
2. Enter the HarnessKit repository URL and click **Add Package**.
3. Assign `HarnessKitScreenshots` to your **UI test target**. If the macOS Tester app also needs to read config, add it there too.

> Important: `HarnessKitScreenshots` contains XCTest-guarded code (`captureScreenshot`, `updateOrientation`, `resetTheme`). Those functions compile only when `XCTest` is available, so linking to a non-test target is safe.

## Defining a Screenshot

Create a `Screenshot` value for each screen you want to capture:

```swift
import HarnessKitScreenshots

let homeLight = Screenshot(
    id: "home",
    appearance: .light,
    os: .iOS,
    osVersion: "18.2",
    backgroundHex: "F2F2F7"
)

let homeDark = Screenshot(
    id: "home",
    appearance: .dark,
    os: .iOS,
    osVersion: "18.2",
    backgroundHex: "1C1C1E"
)
```

## Capturing in a UI Test

Call `captureScreenshot` inside an `XCTestCase`. The function sets the device appearance, waits for animations to settle, and attaches the PNG to the test run:

```swift
import XCTest
import HarnessKitScreenshots

final class ScreenshotTests: XCTestCase {

    func testHomeScreen() {
        let app = XCUIApplication()
        app.launch()

        for screenshot in [homeLight, homeDark] {
            captureScreenshot(screenshot: screenshot, app: app, add: add)
        }
    }
}
```

Pass a `sleepSeconds` value when the UI needs longer to settle, or a `customActions` closure to run additional setup before capture:

```swift
captureScreenshot(
    screenshot: homeLight,
    app: app,
    sleepSeconds: 3,
    customActions: { app.buttons["Load"].tap() },
    add: add
)
```

## Setting Orientation

Call `updateOrientation()` before launching the app. It reads `ScreenshotConfig.load()` and rotates the simulator to match the configured orientation for the current device type:

```swift
override func setUp() {
    super.setUp()
    updateOrientation()
}
```

## Loading Config in the Tester App

On macOS, load the bundled config to drive the transform tool:

```swift
import HarnessKitScreenshots

let config = await ScreenshotConfig.load()
```

Override any field programmatically before passing it to `HarnessKitTransform`:

```swift
var config = await ScreenshotConfig.load()
config.resolution = .full
```

## Troubleshooting

- **`captureScreenshot` not found**: Confirm `HarnessKitScreenshots` is linked to the UI test target and you have `import HarnessKitScreenshots` at the top of the file.
- **Appearance not applied on watchOS**: watchOS does not support `XCUIDevice.appearance`. The `captureScreenshot` function skips the appearance step on watchOS automatically.
- **Config loads defaults instead of JSON**: Make sure `config.json` is inside `Sources/HarnessKitScreenshots/Resources/` and the target declares `resources: [.process("Resources")]` in `Package.swift`.

## Next Steps

- <doc:HarnessKitScreenshots>
- <doc:AboutHarnessKitScreenshots>

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

Integrate the screenshot data types into your project and configure the transform pipeline.

## Overview

`HarnessKitScreenshots` is the **model library** — it defines ``Screenshot``, ``ScreenshotConfig``, and all supporting types. It contains no XCTest code.

To **capture** screenshots, add `HarnessKitScreenshotTesting` to your UI test target.
To **transform** screenshots, add `HarnessKitTransform` to your macOS transformer app.

Both depend on `HarnessKitScreenshots` for the shared types.

## Adding to Your Project

1. In Xcode, select **File > Add Packages...**.
2. Enter the HarnessKit repository URL and click **Add Package**.
3. Assign libraries to the correct targets:

| Library | Target | Purpose |
| :--- | :--- | :--- |
| `HarnessKitScreenshots` | App target, macOS transformer | Shared model types |
| `HarnessKitScreenshotTesting` | UI test target | `captureScreenshot`, `updateOrientation`, `resetTheme` |
| `HarnessKitTransform` | macOS transformer app | Image pipeline, bezel compositing |

> Important: `HarnessKitScreenshots` has **no XCTest dependency**. It is safe to link to any target. The XCTest functions live in `HarnessKitScreenshotTesting`.

## Defining a Screenshot

Create a ``Screenshot`` value for each screen you want to capture. The `os` and `osVersion` are set automatically by the capture infrastructure:

```swift
import HarnessKitScreenshots

let homeLight = Screenshot(
    id: "home",
    appearance: .light,
    background: .solid(hex: "F2F2F7"),
    shadows: [.drop(DropShadow(opacity: 0.4, blur: 0.02))],
    addBezel: true
)

let homeDark = Screenshot(
    id: "home",
    appearance: .dark,
    background: .solid(hex: "1C1C1E"),
    shadows: [.drop(DropShadow(opacity: 0.5, blur: 0.02))]
)
```

## Capturing in a UI Test

Import `HarnessKitScreenshotTesting` (not `HarnessKitScreenshots`) in your test file to access the capture function:

```swift
import XCTest
import HarnessKitScreenshotTesting

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

### What Happens During Capture

1. `captureScreenshot` sets `XCUIDevice.shared.appearance` from ``Screenshot/appearance``.
2. Sleeps to let the UI settle (default 2 seconds).
3. Captures the screen and creates an `XCTAttachment`.
4. The attachment name is set via ``Screenshot/screenshotName()`` — a flat `key*value^key*value.png` string encoding `id`, `os`, `appearance`, `crop`, `background`, `osVersion`, and `addBezel`.
5. The **full** ``Screenshot`` (including ``Screenshot/shadows``) is also embedded as JSON inside the PNG via ``ScreenshotMetadata``.

### What Goes in the Filename vs. PNG Metadata

| Data | Filename | PNG Metadata |
| :--- | :--- | :--- |
| `id`, `os`, `appearance`, `orientation`, `crop`, `background`, `osVersion`, `addBezel` | Yes | Yes |
| `shadows` | **No** (too complex) | **Yes** |
| Full round-trip fidelity | Approximate | **Exact** |

The transform pipeline reads the PNG metadata (not the filename) to reconstruct the full ``Screenshot``.

## Setting Orientation

Call `updateOrientation(config:)` (from `HarnessKitScreenshotTesting`) before launching the app:

```swift
import HarnessKitScreenshotTesting

override func setUp() {
    super.setUp()
    let config = ScreenshotConfig.load(from: myConfigURL)
    updateOrientation(config: config)
}
```

## Configuring the Transform Pipeline

The config JSON is owned by your project. Load it from Application Support or build programmatically:

```swift
import HarnessKitScreenshots

// Load from file
let config = ScreenshotConfig.load(from: myConfigURL)

// Or build from defaults
var config = ScreenshotConfig.defaults
config.phoneBezel = [
    VersionedBezel(minVersion: "26.0", deviceID: "iPhone17", color: "Black")
]
config.resolution = .full
```

Pass the config to `HarnessKitTransform` functions like `processScreenshot(image:screenshot:config:)`.

## Troubleshooting

- **`captureScreenshot` not found**: You need `import HarnessKitScreenshotTesting`, not `import HarnessKitScreenshots`. The capture function lives in the testing library.
- **Appearance not applied on watchOS**: watchOS does not support `XCUIDevice.appearance`. The capture function skips this step automatically.
- **Config loads defaults**: ``ScreenshotConfig/load(from:)`` returns `.defaults` if the file doesn't exist or can't be decoded. Verify the URL points to a valid JSON file.
- **Shadows missing after round-trip**: If you parse from the filename string via ``Screenshot/fromScreenshotName(_:)``, shadows are lost. Use ``ScreenshotMetadata/read(from:)`` to read the full ``Screenshot`` from the PNG.

## Next Steps

- <doc:HarnessKitScreenshots>
- <doc:AboutHarnessKitScreenshots>

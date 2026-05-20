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

Wire `HarnessKitScreenshots` into your project and describe the screenshots you want to capture.

## Overview

`HarnessKitScreenshots` is a model-only library. It defines ``Screenshot`` and the enums it uses. No `XCTest`, no rendering, no platform gating beyond a single iOS-only computed property on ``ScreenOrientation``.

You almost always pair it with `HarnessKitScreenshotTesting`, which adds the capture functions and pulls `HarnessKitScreenshots` in transitively.

## Adding to Your Project

1. In Xcode, choose **File > Add Packages...**.
2. Paste the HarnessKit repository URL and click **Add Package**.
3. Assign the libraries to the right targets:

| Library | Target | Purpose |
| :--- | :--- | :--- |
| `HarnessKitScreenshots` | App target or UI test target | The ``Screenshot`` type and its enums |
| `HarnessKitScreenshotTesting` | UI test target | The capture, orientation, and theme functions |

You only need to link `HarnessKitScreenshots` directly if you construct ``Screenshot`` values from app code, for example to keep the IDs in sync with the screens themselves. If every ``Screenshot`` lives in the test file, the testing library brings it in for you.

## Describing a Screenshot

Build one ``Screenshot`` per frame you want to capture. The capture infrastructure fills in ``Screenshot/osVersion`` from the running simulator, so you do not pass it in.

```swift
import HarnessKitScreenshots

let homeLight = Screenshot(
    id: "home",
    appearance: .light
)

let homeDark = Screenshot(
    id: "home",
    appearance: .dark
)

let landscape = Screenshot(
    id: "detail",
    appearance: .light,
    orientation: .landscape
)
```

If you set ``Screenshot/orientation``, `captureScreenshot` rotates the iOS simulator to match before grabbing the frame. Other platforms ignore it.

If you set ``Screenshot/addBezel`` to `false`, the attached filename records that decision so any downstream tool can skip bezel compositing. The library itself does not render bezels.

## Capturing in a UI Test

Capture lives in `HarnessKitScreenshotTesting`. Import it (not `HarnessKitScreenshots`) and call ``HarnessKitScreenshotTesting/captureScreenshot(screenshot:app:sleepSeconds:customActions:add:)``:

```swift
import XCTest
import HarnessKitScreenshotTesting

final class ScreenshotTests: XCTestCase {
    func testHomeScreen() {
        let app = XCUIApplication()
        app.launch()

        for shot in [homeLight, homeDark] {
            captureScreenshot(screenshot: shot, app: app, add: add)
        }
    }
}
```

The function sets the device appearance, sleeps for two seconds by default, captures the screen, and attaches the PNG with ``Screenshot/screenshotName()`` as its filename.

## Reading Screenshots Back

When you process the attached PNGs in a separate tool, you reconstruct the original ``Screenshot`` from the filename.

```swift
import HarnessKitScreenshots

let url: URL = ...
if let shot = Screenshot.fromScreenshotName(url.lastPathComponent) {
    print(shot.id, shot.appearance, shot.osVersion ?? "unknown")
}
```

`fromScreenshotName(_:)` returns `nil` when the filename is missing `id`, `os`, or `appearance`. Everything else is recoverable as long as the file was named by ``Screenshot/screenshotName()``.

## Troubleshooting

- **`captureScreenshot` is unresolved.** You imported `HarnessKitScreenshots` in your test. Import `HarnessKitScreenshotTesting` instead.
- **`appearance` does not change on watchOS.** Expected. watchOS does not expose `XCUIDevice.shared.appearance`, so the capture skips that step. Light captures still go through.
- **`orientation` does nothing on macOS or tvOS.** Also expected. Only iOS supports orientation rotation through `XCUIDevice.shared.orientation`.

## Next Steps

- <doc:HarnessKitScreenshots>
- <doc:AboutHarnessKitScreenshots>

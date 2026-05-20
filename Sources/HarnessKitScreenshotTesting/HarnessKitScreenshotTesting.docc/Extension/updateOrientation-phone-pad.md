# ``HarnessKitScreenshotTesting/updateOrientation(phone:pad:)``

Rotates the iOS simulator based on the running device idiom.

@Metadata {
    @SupportedLanguage(swift)
    @Available(iOS, introduced: "14.0")
    @Available(iPadOS, introduced: "14.0")
    @DocumentationExtension(mergeBehavior: override)
}

@Options {
    @AutomaticSeeAlso(disabled)
    @AutomaticArticleSubheading(disabled)
}

## Overview

Call `updateOrientation(phone:pad:)` in `XCTestCase.setUp()` to rotate the iOS simulator before the test runs. The function reads `UIDevice.current.userInterfaceIdiom` and picks `phone` on iPhone or `pad` on iPad. It writes the chosen value to `XCUIDevice.shared.orientation` and sleeps for two seconds so the simulator can finish rotating.

The function is a no-op on every platform except iOS.

### Usage

Default behavior keeps phones portrait and iPads landscape:

```swift
import HarnessKitScreenshotTesting

override func setUp() {
    super.setUp()
    updateOrientation()
}
```

Override either side for a specific test:

```swift
updateOrientation(phone: .landscape, pad: .landscape)
```

If you want to force one orientation regardless of idiom, reach for ``setOrientation(to:)`` instead.

## Parameters

| Name | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `phone` | `ScreenOrientation` | `.portrait` | Orientation applied when the running idiom is iPhone. |
| `pad` | `ScreenOrientation` | `.landscape` | Orientation applied when the running idiom is iPad. |

## See Also

- ``setOrientation(to:)``
- ``captureScreenshot(screenshot:app:sleepSeconds:customActions:add:)``

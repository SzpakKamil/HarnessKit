# ``HarnessKitScreenshotTesting/setOrientation(to:)``

Sets the iOS simulator to a specific orientation.

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

Sets `XCUIDevice.shared.orientation` to the UIKit value for the given `ScreenOrientation` and sleeps for 2 seconds so the simulator can finish rotating. Reach for this when a single test needs a specific rotation, separate from the idiom-driven default that ``updateOrientation(phone:pad:)`` applies in `setUp()`.

The function is a no-op on every platform except iOS.

```swift
setOrientation(to: .landscape)
// simulator rotates to landscape
```

## Parameters

| Name | Type | Description |
| :--- | :--- | :--- |
| `orientation` | `ScreenOrientation` | `.portrait` or `.landscape`. |

## See Also

- ``updateOrientation(phone:pad:)``
- ``captureScreenshot(screenshot:app:sleepSeconds:customActions:add:)``

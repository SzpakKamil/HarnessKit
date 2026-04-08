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

Sets `XCUIDevice.shared.orientation` to the UIKit value for the given `ScreenOrientation` and sleeps for 2 seconds to let the simulator settle. Use this when you need to force a specific orientation mid-test rather than reading from `ScreenshotConfig`.

This function is a **no-op on all platforms except iOS**.

```swift
setOrientation(to: .landscape)
// simulator rotates to landscape
```

## Parameters

| Name | Type | Description |
| :--- | :--- | :--- |
| `orientation` | `ScreenOrientation` | `.portrait` or `.landscape`. |

## See Also

- ``updateOrientation(config:)``

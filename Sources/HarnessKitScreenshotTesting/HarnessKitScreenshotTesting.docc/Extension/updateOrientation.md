# ``HarnessKitScreenshotTesting/updateOrientation(config:)``

Sets the iOS simulator orientation from the screenshot config before a test runs.

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

Call `updateOrientation(config:)` in `XCTestCase.setUp()` to rotate the iOS simulator to the orientation configured in `ScreenshotConfig`. On iPhone it applies `ScreenshotConfig/phoneOrientation`; on iPad it applies `ScreenshotConfig/padOrientation`. After rotating, the function sleeps for 2 seconds to let the simulator settle.

This function is a **no-op on all platforms except iOS**.

### Usage

```swift
import HarnessKitScreenshotTesting

override func setUp() {
    super.setUp()
    let config = ScreenshotConfig.load(from: myConfigURL)
    updateOrientation(config: config)
}
```

If no config file is available, the default parameter uses `ScreenshotConfig/defaults`:

```swift
updateOrientation()  // uses .defaults
```

## Parameters

| Name | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `config` | `ScreenshotConfig` | `.defaults` | The config to read orientation from. |

## See Also

- ``setOrientation(to:)``
- ``captureScreenshot(screenshot:app:sleepSeconds:customActions:add:)``

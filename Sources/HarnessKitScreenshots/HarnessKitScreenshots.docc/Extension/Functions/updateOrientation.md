# ``HarnessKitScreenshots/updateOrientation()``

@Metadata {
    @SupportedLanguage(swift)
    @Available(iOS, introduced: "14.0")
    @DocumentationExtension(mergeBehavior: override)
}

@Options {
    @AutomaticArticleSubheading(disabled)
}

Sets the iOS simulator orientation from the global screenshot config before a test runs.

## Overview

Call `updateOrientation()` in `XCTestCase.setUp()` to rotate the simulator to the orientation configured in `ScreenshotConfig`. On iPhone it applies `phoneOrientation`; on iPad it applies `padOrientation`. After rotating, the function sleeps for 2 seconds to let the simulator settle.

The function is a no-op on all platforms except iOS.

```swift
final class ScreenshotTests: XCTestCase {
    override func setUp() {
        super.setUp()
        updateOrientation()
    }
}
```

`updateOrientation()` calls `ScreenshotConfig.load()` internally. If you need to drive orientation from a custom config, set `XCUIDevice.shared.orientation` directly instead.

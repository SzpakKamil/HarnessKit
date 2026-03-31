# ``HarnessKitScreenshots/resetTheme(to:)``

@Metadata {
    @SupportedLanguage(swift)
    @Available(macOS, introduced: "12.0")
    @Available(iOS, introduced: "14.0")
    @Available(tvOS, introduced: "14.0")
    @DocumentationExtension(mergeBehavior: override)
}

@Options {
    @AutomaticArticleSubheading(disabled)
}

Sets the device appearance for UI tests.

## Overview

`resetTheme(to:)` writes to `XCUIDevice.shared.appearance`. Call it when you need to switch the color scheme between test cases rather than relying on the per-screenshot logic in `captureScreenshot`.

```swift
resetTheme(to: .dark)
sleep(1)
// take manual screenshot or assert dark-mode UI
```

The function is a no-op on watchOS, which does not support `XCUIDevice.appearance`.

> Important: Requires macOS 12.0 or later. On macOS 11 the `appearance` property is unavailable.

## See Also

- ``currentTheme()``
- ``captureScreenshot(screenshot:app:sleepSeconds:customActions:add:)``

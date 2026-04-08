# ``HarnessKitScreenshotTesting/resetTheme(to:)``

Sets the device appearance for UI tests.

@Metadata {
    @SupportedLanguage(swift)
    @Available(macOS, introduced: "12.0")
    @Available(iOS, introduced: "15.0")
    @Available(tvOS, introduced: "15.0")
    @Available(visionOS, introduced: "1.0")
    @DocumentationExtension(mergeBehavior: override)
}

@Options {
    @AutomaticSeeAlso(disabled)
    @AutomaticArticleSubheading(disabled)
}

## Overview

Writes to `XCUIDevice.shared.appearance`. Use this when you need to switch the color scheme between test cases rather than relying on the per-screenshot logic in ``captureScreenshot(screenshot:app:sleepSeconds:customActions:add:)``.

No-op on watchOS (appearance switching is unsupported).

```swift
resetTheme(to: .dark)
sleep(1)
// assert dark-mode UI or capture manually
```

### Saving and Restoring

Pair with ``currentTheme()`` to restore the original appearance after a test:

```swift
let before = currentTheme()
resetTheme(to: .dark)
// ... test dark mode ...
resetTheme(to: before)
```

> Important: Requires macOS 12.0+ / iOS 15.0+ / tvOS 15.0+.

## Parameters

| Name | Type | Description |
| :--- | :--- | :--- |
| `appearance` | `XCUIDevice.Appearance` | `.light`, `.dark`, or `.unspecified`. |

## See Also

- ``currentTheme()``
- ``captureScreenshot(screenshot:app:sleepSeconds:customActions:add:)``

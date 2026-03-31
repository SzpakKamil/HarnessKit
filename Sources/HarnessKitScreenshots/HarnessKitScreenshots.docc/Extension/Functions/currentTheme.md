# ``HarnessKitScreenshots/currentTheme()``

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

Returns the current device appearance during a UI test.

## Overview

`currentTheme()` reads `XCUIDevice.shared.appearance` and returns it as an `XCUIDevice.Appearance` value. On watchOS, where `XCUIDevice.appearance` is unavailable, it returns `.unspecified`.

```swift
let before = currentTheme()
resetTheme(to: .dark)
// assert or capture
resetTheme(to: before) // restore
```

> Important: Requires macOS 12.0 or later.

## See Also

- ``resetTheme(to:)``

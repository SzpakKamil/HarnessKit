# ``HarnessKitScreenshotTesting/currentTheme()``

Returns the current device appearance during a UI test.

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

Reads `XCUIDevice.shared.appearance` and returns the current value. On watchOS, where appearance switching is unsupported, returns `.unspecified`.

Use this to save the current theme before switching, so you can restore it afterwards:

```swift
let before = currentTheme()
resetTheme(to: .dark)
// ... capture dark-mode screenshots ...
resetTheme(to: before)
```

> Important: Requires macOS 12.0+ / iOS 15.0+ / tvOS 15.0+.

## See Also

- ``resetTheme(to:)``

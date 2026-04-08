# ``HarnessKitScreenshots/Screenshot/init(id:appearance:os:orientation:crop:backgroundHex:shadows:addBezel:)``

@Metadata {
    @SupportedLanguage(swift)
    @Available(iOS, introduced: "14.0")
    @Available(iPadOS, introduced: "14.0")
    @Available(macOS, introduced: "11.0")
    @Available(tvOS, introduced: "14.0")
    @Available(watchOS, introduced: "10.0")
    @Available(visionOS, introduced: "1.0")
    @DocumentationExtension(mergeBehavior: override)
}
@Options {
    @AutomaticSeeAlso(disabled)
    @AutomaticArticleSubheading(disabled)
}

Creates a screenshot descriptor with an optional solid hex background color.

## Overview

Use this initializer when you need a simple solid-color background specified as a hex string (for example `"F2F2F7"`). The hex value is wrapped into ``ScreenshotBackground/solid(hex:)`` internally. If `backgroundHex` is `nil`, no background is drawn. Most parameters have sensible defaults: `os` defaults to the current platform, `orientation` to `nil`, `crop` to the full frame, `shadows` to an empty array, and `addBezel` to `true`.

## See Also
- ``HarnessKitScreenshots/Screenshot``
- ``HarnessKitScreenshots/Screenshot/init(id:appearance:os:orientation:crop:background:shadows:addBezel:)``

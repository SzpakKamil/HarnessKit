# ``HarnessKitScreenshots/Screenshot/init(id:appearance:os:orientation:crop:background:shadows:addBezel:)``

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

Creates a screenshot descriptor with a typed background.

## Overview

Use this initializer when you need a gradient, image, or solid-color background expressed as a ``ScreenshotBackground`` value. This provides full control over the background type, unlike the hex-based initializer which only supports solid colors. Pass `nil` for a transparent canvas. All other parameters share the same defaults as the hex-based initializer: `os` defaults to the current platform, `orientation` to `nil`, `crop` to the full frame, `shadows` to an empty array, and `addBezel` to `true`.

## See Also
- ``HarnessKitScreenshots/Screenshot``
- ``HarnessKitScreenshots/Screenshot/init(id:appearance:os:orientation:crop:backgroundHex:shadows:addBezel:)``
- ``HarnessKitScreenshots/ScreenshotBackground``

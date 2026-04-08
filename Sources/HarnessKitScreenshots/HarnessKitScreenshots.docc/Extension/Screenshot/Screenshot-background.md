# ``HarnessKitScreenshots/Screenshot/background``

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

The background fill rendered behind the device frame.

## Overview

`background` accepts a ``ScreenshotBackground`` value that the transform pipeline draws behind the composited device bezel. It supports solid colors, gradients, and named images. When `nil`, no background is drawn and the output retains a transparent canvas. Use the ``init(id:appearance:os:orientation:crop:background:shadows:addBezel:)`` initializer to set a typed background directly, or use ``init(id:appearance:os:orientation:crop:backgroundHex:shadows:addBezel:)`` for a simple solid hex color.

## See Also
- ``HarnessKitScreenshots/Screenshot``
- ``HarnessKitScreenshots/ScreenshotBackground``
- ``HarnessKitScreenshots/Screenshot/backgroundHex``

# ``HarnessKitScreenshots/ScreenshotBackground/solid(hex:)``

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

Fills the screenshot background with a solid color.

## Overview

Pass a six-character hex string (e.g. `"FF0000"` for red) to produce a uniform color fill behind the device bezel. The hex value is stored as-is in the ``Screenshot`` metadata and resolved to a platform color at render time.

This is the simplest background option and works well when the screenshot content already provides enough visual context on its own.

## See Also
- ``HarnessKitScreenshots/ScreenshotBackground/gradient(startHex:endHex:angle:)``
- ``HarnessKitScreenshots/ScreenshotBackground/image(name:directory:scale:offsetX:offsetY:)``

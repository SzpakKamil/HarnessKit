# ``HarnessKitScreenshots/ScreenshotBackground/gradient(startHex:endHex:angle:)``

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

Fills the screenshot background with a linear gradient between two colors.

## Overview

Specify the start and end colors as six-character hex strings and an angle in degrees that controls the gradient direction. The angle follows standard conventions: 0 degrees draws from bottom to top, 90 degrees from left to right, 180 degrees from top to bottom, and 270 degrees from right to left.

Gradients add visual depth behind the device bezel and are useful for App Store marketing assets where a flat color feels too plain.

## See Also
- ``HarnessKitScreenshots/ScreenshotBackground/solid(hex:)``
- ``HarnessKitScreenshots/ScreenshotBackground/image(name:directory:scale:offsetX:offsetY:)``

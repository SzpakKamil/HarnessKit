# ``HarnessKitScreenshots/DropShadow/offsetY``

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

The vertical shadow offset as a fraction of the device's short side.

## Overview

Positive values shift the shadow downward, negative values shift it upward. A small positive offset simulates a light source above the device, which is the most natural-looking configuration for marketing screenshots.

The default value is `0.01`.

## See Also
- ``HarnessKitScreenshots/DropShadow/offsetX``
- ``HarnessKitScreenshots/DropShadow/blur``

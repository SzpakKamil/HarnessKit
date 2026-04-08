# ``HarnessKitScreenshots/ShapeShadow/x``

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

The horizontal center offset as a fraction of the device's short side.

## Overview

A value of `0` centers the shape shadow horizontally relative to the device. Positive values shift it to the right, negative values to the left. This is useful for placing contact shadows precisely beneath the device or for creating asymmetric shadow effects.

The default value is `0`.

## See Also
- ``HarnessKitScreenshots/ShapeShadow/y``
- ``HarnessKitScreenshots/ShapeShadow/width``

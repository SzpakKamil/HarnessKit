# ``HarnessKitScreenshots/DropShadow/offsetX``

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

The horizontal shadow offset as a fraction of the device's short side.

## Overview

Positive values shift the shadow to the right, negative values shift it to the left. A value of `0` keeps the shadow horizontally centered behind the device. Like all spatial properties on ``DropShadow``, this is resolution-independent.

The default value is `0`.

## See Also
- ``HarnessKitScreenshots/DropShadow/offsetY``
- ``HarnessKitScreenshots/DropShadow/blur``

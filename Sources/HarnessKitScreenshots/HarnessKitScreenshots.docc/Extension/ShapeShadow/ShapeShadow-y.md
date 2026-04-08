# ``HarnessKitScreenshots/ShapeShadow/y``

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

The vertical center offset as a fraction of the device's short side.

## Overview

A value of `0` centers the shape shadow vertically relative to the device. Negative values shift it upward (toward the bottom of the device in screen coordinates), which is the typical placement for a contact shadow beneath a floating device.

The default value is `-1.1`, which positions the shadow just below the device.

## See Also
- ``HarnessKitScreenshots/ShapeShadow/x``
- ``HarnessKitScreenshots/ShapeShadow/height``

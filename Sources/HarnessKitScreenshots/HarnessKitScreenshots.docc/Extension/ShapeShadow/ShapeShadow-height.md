# ``HarnessKitScreenshots/ShapeShadow/height``

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

The shape height as a fraction of the device's short side.

## Overview

Defines the vertical extent of the shadow shape before blur is applied. For contact shadows, this is typically much smaller than ``width`` to produce a thin, horizontally elongated ellipse that simulates a surface beneath the device.

The default value is `0.025`.

## See Also
- ``HarnessKitScreenshots/ShapeShadow/width``
- ``HarnessKitScreenshots/ShapeShadow/cornerRadius``

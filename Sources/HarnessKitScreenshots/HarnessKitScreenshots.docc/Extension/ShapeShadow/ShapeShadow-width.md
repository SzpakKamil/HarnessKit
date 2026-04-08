# ``HarnessKitScreenshots/ShapeShadow/width``

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

The shape width as a fraction of the device's short side.

## Overview

Defines the horizontal extent of the shadow shape before blur is applied. A value of `1.0` matches the device's short side exactly. Values greater than `1.0` extend the shadow wider than the device, which is common for contact shadow ellipses that need to look proportional beneath a tall device.

The default value is `1.7`.

## See Also
- ``HarnessKitScreenshots/ShapeShadow/height``
- ``HarnessKitScreenshots/ShapeShadow/cornerRadius``

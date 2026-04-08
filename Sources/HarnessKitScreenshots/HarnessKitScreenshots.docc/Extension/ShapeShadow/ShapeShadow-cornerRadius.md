# ``HarnessKitScreenshots/ShapeShadow/cornerRadius``

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

The corner radius factor from 0 (rectangle) to 1 (full ellipse).

## Overview

Controls the roundness of the shadow shape. A value of `0` produces a sharp rectangle, while `1` produces a fully rounded ellipse. Intermediate values create a rounded rectangle. For contact shadows, a value of `1` is typical since the thin ellipse shape looks most natural beneath a floating device.

The default value is `1`.

## See Also
- ``HarnessKitScreenshots/ShapeShadow/width``
- ``HarnessKitScreenshots/ShapeShadow/height``

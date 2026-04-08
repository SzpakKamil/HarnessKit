# ``HarnessKitScreenshots/ShapeShadow/init(color:opacity:blur:x:y:width:height:cornerRadius:)``

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

Creates a shape shadow with the specified geometry and visual properties.

## Overview

All parameters have defaults that produce a contact shadow ellipse positioned just below the device. The default configuration is a wide, thin, fully rounded black shape at 30% opacity with moderate blur, centered horizontally and offset downward.

All spatial parameters are fractions of the device's short side, keeping the shadow proportional across different resolutions and device sizes without manual tweaking.

## See Also
- ``HarnessKitScreenshots/ShapeShadow``
- ``HarnessKitScreenshots/ScreenshotShadow/shape(_:)``

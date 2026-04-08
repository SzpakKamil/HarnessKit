# ``HarnessKitScreenshots/DropShadow/init(color:opacity:blur:offsetX:offsetY:)``

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

Creates a drop shadow with the specified visual properties.

## Overview

All parameters have sensible defaults that produce a subtle downward shadow suitable for most bezel screenshots. The default configuration uses a black color at 50% opacity with a small blur radius and a slight downward offset.

All spatial parameters (blur, offsetX, offsetY) are fractions of the device's short side, so the shadow scales proportionally across resolutions without any manual adjustment.

## See Also
- ``HarnessKitScreenshots/DropShadow``
- ``HarnessKitScreenshots/ScreenshotShadow/drop(_:)``

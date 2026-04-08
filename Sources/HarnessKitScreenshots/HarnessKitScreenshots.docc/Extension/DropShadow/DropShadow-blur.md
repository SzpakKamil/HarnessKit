# ``HarnessKitScreenshots/DropShadow/blur``

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

The blur radius as a fraction of the device's short side.

## Overview

A larger blur value produces a softer, more diffuse shadow. Because the value is expressed as a fraction of the device's short side, the visual result scales proportionally across different device resolutions.

The default value is `0.02`.

## See Also
- ``HarnessKitScreenshots/DropShadow/opacity``
- ``HarnessKitScreenshots/DropShadow/offsetX``
- ``HarnessKitScreenshots/DropShadow/offsetY``

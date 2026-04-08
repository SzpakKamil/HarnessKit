# ``HarnessKitScreenshots/ShapeShadow/blur``

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

Controls how soft the edges of the shape shadow appear. A larger blur creates a more diffuse, natural-looking shadow. Because the value is a fraction of the device's short side, results are consistent across different device resolutions.

The default value is `0.06`.

## See Also
- ``HarnessKitScreenshots/ShapeShadow/opacity``
- ``HarnessKitScreenshots/ShapeShadow/width``
- ``HarnessKitScreenshots/ShapeShadow/height``

# ``HarnessKitScreenshots/Screenshot/crop``

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

The crop and zoom rectangle applied to the final composited output.

## Overview

`crop` defines a normalized rectangle that the transform pipeline uses to crop or zoom the rendered screenshot. The default value of `CropRect(x: 0, y: 0, width: 1, height: 1)` represents the full image with no cropping. Setting `width` and `height` above `1.0` zooms into the content, while adjusting `x` and `y` pans the viewport. This is useful for highlighting a specific area of the screen in the final App Store image without re-capturing.

## See Also
- ``HarnessKitScreenshots/Screenshot``
- ``HarnessKitScreenshots/CropRect``

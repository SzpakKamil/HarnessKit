# ``HarnessKitScreenshots/CropRect/init(x:y:width:height:)``

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

Creates a crop rectangle with the specified offset and zoom values.

## Overview

Initializes a new `CropRect` with normalized pan offsets and zoom factors. The `x` and `y` parameters accept values from `-1.0` to `1.0` to control panning, while `width` and `height` use `1.0` as the baseline for no zoom. Pass values less than `1.0` for width and height to zoom into the image.

## See Also

- ``HarnessKitScreenshots/CropRect/x``
- ``HarnessKitScreenshots/CropRect/y``
- ``HarnessKitScreenshots/CropRect/width``
- ``HarnessKitScreenshots/CropRect/height``

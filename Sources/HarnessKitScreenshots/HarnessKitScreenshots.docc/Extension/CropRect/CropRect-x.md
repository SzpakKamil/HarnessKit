# ``HarnessKitScreenshots/CropRect/x``

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

The horizontal pan offset, normalized from -1.0 to 1.0.

## Overview

Controls the horizontal position of the crop region within the source image. A value of `0.0` centers the crop horizontally. Negative values shift the visible area to the left, while positive values shift it to the right. The range is `-1.0` to `1.0`.

## See Also

- ``HarnessKitScreenshots/CropRect/y``
- ``HarnessKitScreenshots/CropRect/width``

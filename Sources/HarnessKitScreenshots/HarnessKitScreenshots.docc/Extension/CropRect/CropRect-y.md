# ``HarnessKitScreenshots/CropRect/y``

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

The vertical pan offset, normalized from -1.0 to 1.0.

## Overview

Controls the vertical position of the crop region within the source image. A value of `0.0` centers the crop vertically. Negative values shift the visible area upward, while positive values shift it downward. The range is `-1.0` to `1.0`.

## See Also

- ``HarnessKitScreenshots/CropRect/x``
- ``HarnessKitScreenshots/CropRect/height``

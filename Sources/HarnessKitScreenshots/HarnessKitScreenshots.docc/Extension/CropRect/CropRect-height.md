# ``HarnessKitScreenshots/CropRect/height``

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

The vertical zoom factor for the crop region.

## Overview

Defines the height of the visible crop area as a zoom factor. A value of `1.0` means no vertical zoom (the full height is visible). Values less than `1.0` zoom in, showing a shorter portion of the source image. Combine with ``HarnessKitScreenshots/CropRect/y`` to control which vertical slice is visible.

## See Also

- ``HarnessKitScreenshots/CropRect/width``
- ``HarnessKitScreenshots/CropRect/y``

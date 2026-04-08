# ``HarnessKitScreenshots/CropRect/width``

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

The horizontal zoom factor for the crop region.

## Overview

Defines the width of the visible crop area as a zoom factor. A value of `1.0` means no horizontal zoom (the full width is visible). Values less than `1.0` zoom in, showing a narrower portion of the source image. Combine with ``HarnessKitScreenshots/CropRect/x`` to control which horizontal slice is visible.

## See Also

- ``HarnessKitScreenshots/CropRect/height``
- ``HarnessKitScreenshots/CropRect/x``

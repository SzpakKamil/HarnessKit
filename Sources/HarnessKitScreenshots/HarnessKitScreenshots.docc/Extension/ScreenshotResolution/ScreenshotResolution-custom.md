# ``HarnessKitScreenshots/ScreenshotResolution/custom(width:height:)``

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

A custom resolution with caller-specified width and height.

## Overview

Use `custom(width:height:)` when neither the ``HarnessKitScreenshots/ScreenshotResolution/full`` nor ``HarnessKitScreenshots/ScreenshotResolution/default`` presets match your requirements. The associated `width` and `height` integer values are converted to a `CGSize` by the ``HarnessKitScreenshots/ScreenshotResolution/size`` property.

## See Also

- ``HarnessKitScreenshots/ScreenshotResolution/full``
- ``HarnessKitScreenshots/ScreenshotResolution/default``
- ``HarnessKitScreenshots/ScreenshotResolution/size``

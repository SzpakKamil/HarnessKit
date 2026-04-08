# ``HarnessKitScreenshots/ScreenshotResolution/default``

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

A standard-resolution preset at 603 by 416 points.

## Overview

Use `default` for a compact resolution suitable for thumbnail previews or lightweight rendering. The corresponding ``HarnessKitScreenshots/ScreenshotResolution/size`` returns a `CGSize` of 603 by 416. This is the baseline resolution when no specific size requirement exists.

## See Also

- ``HarnessKitScreenshots/ScreenshotResolution/full``
- ``HarnessKitScreenshots/ScreenshotResolution/custom(width:height:)``
- ``HarnessKitScreenshots/ScreenshotResolution/size``

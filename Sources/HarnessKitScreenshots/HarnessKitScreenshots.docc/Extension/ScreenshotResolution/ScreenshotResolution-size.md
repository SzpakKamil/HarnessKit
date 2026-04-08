# ``HarnessKitScreenshots/ScreenshotResolution/size``

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

The concrete `CGSize` represented by this resolution.

## Overview

Converts the resolution case into a `CGSize` value. For ``HarnessKitScreenshots/ScreenshotResolution/full``, the size is 2089 by 1440. For ``HarnessKitScreenshots/ScreenshotResolution/default``, the size is 603 by 416. For ``HarnessKitScreenshots/ScreenshotResolution/custom(width:height:)``, the size matches the associated width and height values.

## See Also

- ``HarnessKitScreenshots/ScreenshotResolution/full``
- ``HarnessKitScreenshots/ScreenshotResolution/default``
- ``HarnessKitScreenshots/ScreenshotResolution/custom(width:height:)``

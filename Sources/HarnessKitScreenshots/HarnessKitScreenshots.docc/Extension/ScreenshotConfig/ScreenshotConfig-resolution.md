# ``HarnessKitScreenshots/ScreenshotConfig/resolution``

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

The output resolution for transformed screenshots.

## Overview

`resolution` controls the final pixel dimensions of the composited screenshot image. The transform pipeline scales the finished frame -- bezel plus screenshot -- to match this target after all compositing is complete.

Use ``ScreenshotResolution/default`` for standard App Store dimensions or ``ScreenshotResolution/full`` for maximum-quality output. The value applies uniformly to all platforms in this config.

## See Also
- ``HarnessKitScreenshots/ScreenshotConfig``

# ``HarnessKitScreenshots/ScreenshotConfig/padOrientation``

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

The orientation applied to iPad screenshots.

## Overview

`padOrientation` determines whether iPad screenshots are rendered in portrait or landscape within the device bezel. The transform pipeline reads this value when compositing an iPadOS screenshot onto its matched pad bezel.

The default is `.landscape` because most App Store listings showcase iPad apps in landscape. Set this to `.portrait` if your app primarily targets portrait use on iPad.

## See Also
- ``HarnessKitScreenshots/ScreenshotConfig``

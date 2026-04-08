# ``HarnessKitScreenshots/ScreenshotConfig/phoneOrientation``

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

The orientation applied to iPhone screenshots.

## Overview

`phoneOrientation` determines whether iPhone screenshots are rendered in portrait or landscape within the device bezel. The transform pipeline reads this value when compositing an iOS screenshot onto its matched phone bezel.

Most App Store listings use portrait for iPhone, so the default is `.portrait`. Set this to `.landscape` if your app is landscape-only.

## See Also
- ``HarnessKitScreenshots/ScreenshotConfig``

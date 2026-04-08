# ``HarnessKitScreenshots/Screenshot/shadows``

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

The shadow effects applied to the composited device frame.

## Overview

`shadows` contains an ordered array of ``ScreenshotShadow`` values that the transform pipeline renders around the device bezel. Multiple shadows can be layered to achieve depth effects. When the array is empty (the default), no shadows are drawn. These are bezel shadows applied to the device frame itself and are separate from any macOS window shadows that may appear in the captured screenshot.

## See Also
- ``HarnessKitScreenshots/Screenshot``
- ``HarnessKitScreenshots/ScreenshotShadow``
- ``HarnessKitScreenshots/Screenshot/addBezel``

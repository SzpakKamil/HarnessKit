# ``HarnessKitScreenshots/ScreenOrientation/landscape``

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

The landscape screen orientation where width exceeds height.

## Overview

Use the `landscape` case when the screenshot should be rendered in a horizontal orientation. This is common for iPad, Mac, and Apple TV screenshots. The raw value is `"Landscape"`.

On iOS, the corresponding `UIDeviceOrientation` value is `.landscapeLeft`.

## See Also

- ``HarnessKitScreenshots/ScreenOrientation/portrait``

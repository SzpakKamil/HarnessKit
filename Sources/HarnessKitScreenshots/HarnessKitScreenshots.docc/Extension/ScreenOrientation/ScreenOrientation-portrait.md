# ``HarnessKitScreenshots/ScreenOrientation/portrait``

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

The portrait screen orientation where height exceeds width.

## Overview

Use the `portrait` case when the screenshot should be rendered in a vertical orientation. This is the default orientation for most iPhone and Apple Watch screenshots. The raw value is `"Portrait"`.

On iOS, the corresponding `UIDeviceOrientation` value is `.portrait`.

## See Also

- ``HarnessKitScreenshots/ScreenOrientation/landscape``

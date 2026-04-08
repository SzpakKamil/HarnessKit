# ``HarnessKitScreenshots/ScreenOrientation/orientation(fromSize:)``

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

Determines the orientation from a size's aspect ratio.

## Overview

Returns ``HarnessKitScreenshots/ScreenOrientation/landscape`` when the width of the provided `CGSize` is greater than its height, and ``HarnessKitScreenshots/ScreenOrientation/portrait`` otherwise. This is useful for inferring orientation directly from an image or screen dimension without requiring explicit metadata.

## See Also

- ``HarnessKitScreenshots/ScreenOrientation/orientation(from:)``

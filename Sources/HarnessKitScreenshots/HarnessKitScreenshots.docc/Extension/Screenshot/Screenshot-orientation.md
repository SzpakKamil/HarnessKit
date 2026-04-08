# ``HarnessKitScreenshots/Screenshot/orientation``

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

An optional forced orientation applied during the transform phase.

## Overview

When set, `orientation` overrides the natural orientation of the captured screenshot. The transform pipeline uses this value to rotate the image and select the matching bezel frame. Leave it `nil` to keep the orientation as captured. This is primarily useful for iPad screenshots where you want to ensure a specific landscape or portrait layout regardless of the simulator's state at capture time.

## See Also
- ``HarnessKitScreenshots/Screenshot``
- ``HarnessKitScreenshots/ScreenOrientation``

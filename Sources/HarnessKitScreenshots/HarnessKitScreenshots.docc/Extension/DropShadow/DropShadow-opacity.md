# ``HarnessKitScreenshots/DropShadow/opacity``

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

The shadow opacity from 0 (fully transparent) to 1 (fully opaque).

## Overview

Controls how strongly the shadow is visible against the background. Lower values produce a subtle hint of depth, while higher values create a more dramatic effect. This value is multiplied with ``color`` at render time.

The default value is `0.5`.

## See Also
- ``HarnessKitScreenshots/DropShadow/color``
- ``HarnessKitScreenshots/DropShadow/blur``

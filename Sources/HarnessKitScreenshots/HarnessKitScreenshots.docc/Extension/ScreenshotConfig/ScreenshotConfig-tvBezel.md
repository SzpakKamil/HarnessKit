# ``HarnessKitScreenshots/ScreenshotConfig/tvBezel``

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

The versioned bezel array for the tvOS platform.

## Overview

`tvBezel` holds one or more ``VersionedBezel`` entries that map tvOS version ranges to the correct Apple TV frame art. The `color` field is typically set to `"Default"` because the TV frame has no meaningful color variants.

The transform pipeline uses ``ScreenshotConfig/matchedBezel(for:)`` to select the entry whose version range covers the screenshot's `osVersion`, then composites the screenshot into the matched TV display frame.

## See Also
- ``HarnessKitScreenshots/ScreenshotConfig``

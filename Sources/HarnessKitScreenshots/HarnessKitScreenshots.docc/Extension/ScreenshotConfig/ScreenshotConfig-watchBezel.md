# ``HarnessKitScreenshots/ScreenshotConfig/watchBezel``

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

The versioned bezel array for the watchOS platform.

## Overview

`watchBezel` holds one or more ``VersionedBezel`` entries that map watchOS version ranges to the correct Apple Watch hardware art. Each entry should include a `band` value to select the watch band image rendered alongside the case.

The transform pipeline uses ``ScreenshotConfig/matchedBezel(for:)`` to select the entry whose version range covers the screenshot's `osVersion`, then composites the screenshot onto the matched watch case and band combination.

## See Also
- ``HarnessKitScreenshots/ScreenshotConfig``

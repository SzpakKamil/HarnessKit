# ``HarnessKitScreenshots/ScreenshotConfig/matchedBezel(for:)``

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

Returns the best-matching versioned bezel for a given screenshot.

## Overview

`matchedBezel(for:)` inspects the screenshot's `os` to select the correct platform bezel array, then finds the ``VersionedBezel`` entry whose `[minVersion, maxVersion)` range covers `Screenshot.osVersion`. Entries are sorted by `minVersion` in descending order so the highest matching version wins.

When no entry matches -- or when `osVersion` is `nil` -- the method falls back to the entry with the highest `minVersion` in the array. For visionOS screenshots the method always returns `nil` because visionOS frame compositing is not yet supported.

## See Also
- ``HarnessKitScreenshots/ScreenshotConfig``

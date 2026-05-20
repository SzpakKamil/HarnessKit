# ``HarnessKitScreenshots/Screenshot/fromScreenshotName(_:)``

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

Parses a screenshot filename back into a ``Screenshot`` value.

## Overview

`fromScreenshotName(_:)` is the inverse of ``screenshotName()``. It splits the caret-separated `key*value` pairs, reads each property, and rebuilds a `Screenshot`. The method returns `nil` when the string is missing any of `id`, `os`, or `appearance`, or when those required fields contain values the enums cannot decode.

The `.png` suffix is optional. Pass the raw filename, the last path component, or the bare metadata string, and the parser handles all three.

## See Also
- ``HarnessKitScreenshots/Screenshot``
- ``HarnessKitScreenshots/Screenshot/screenshotName()``

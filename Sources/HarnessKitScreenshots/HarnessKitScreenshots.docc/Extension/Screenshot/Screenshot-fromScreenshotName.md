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

Parses a flat-string screenshot name back into a ``Screenshot`` value.

## Overview

`fromScreenshotName(_:)` is the inverse of ``screenshotName()``. It splits the caret-separated `key*value` pairs, extracts each property, and reconstructs a `Screenshot`. Returns `nil` if the string is missing required fields (`id`, `os`, `appearance`, or `crop`) or contains malformed data. The method handles both the current `background` key format and the legacy `backgroundHex` key for backward compatibility. Note that `shadows` are not encoded in the filename, so the returned value always has an empty shadows array.

## See Also
- ``HarnessKitScreenshots/Screenshot``
- ``HarnessKitScreenshots/Screenshot/screenshotName()``

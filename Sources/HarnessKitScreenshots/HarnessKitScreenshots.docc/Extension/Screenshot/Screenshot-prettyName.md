# ``HarnessKitScreenshots/Screenshot/prettyName()``

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

Returns a human-readable display name for this screenshot.

## Overview

`prettyName()` builds a concise, readable string from the screenshot's key identifiers. The format is `id-os` with optional suffixes: the OS version is appended after an underscore when present, and the appearance is appended after a tilde only when it is `.dark`. For example, a dark iOS 18.2 screenshot with id `"home"` produces `"home-iOS_18.2~Dark"`. Use this for UI labels and log output where the full ``screenshotName()`` encoding would be too verbose.

## See Also
- ``HarnessKitScreenshots/Screenshot``
- ``HarnessKitScreenshots/Screenshot/screenshotName()``
- ``HarnessKitScreenshots/Screenshot/id``

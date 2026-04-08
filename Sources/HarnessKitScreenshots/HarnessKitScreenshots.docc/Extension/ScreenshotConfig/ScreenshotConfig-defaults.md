# ``HarnessKitScreenshots/ScreenshotConfig/defaults``

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

A static property returning a sensible default configuration for all platforms.

## Overview

`defaults` provides a ready-made ``ScreenshotConfig`` with a single ``VersionedBezel`` entry per platform, portrait orientation for iPhone, landscape orientation for iPad, and the standard output resolution. This is the fallback used by ``ScreenshotConfig/load(from:)`` when the JSON file is missing or malformed.

Start from `defaults` and override individual properties when you only need to customize a few platforms rather than specifying every value from scratch.

## See Also
- ``HarnessKitScreenshots/ScreenshotConfig``

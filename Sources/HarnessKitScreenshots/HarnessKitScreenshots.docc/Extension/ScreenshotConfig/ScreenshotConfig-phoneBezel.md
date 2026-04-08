# ``HarnessKitScreenshots/ScreenshotConfig/phoneBezel``

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

The versioned bezel array for the iPhone platform.

## Overview

`phoneBezel` holds one or more ``VersionedBezel`` entries that map OS version ranges to the correct iPhone hardware art. During transformation, ``ScreenshotConfig/matchedBezel(for:)`` scans this array to find the entry whose version range covers the screenshot's `osVersion`.

Order does not matter -- the pipeline sorts entries by `minVersion` internally. Include multiple entries when your testers run different iOS versions that require different device frames.

## See Also
- ``HarnessKitScreenshots/ScreenshotConfig``

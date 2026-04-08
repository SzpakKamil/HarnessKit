# ``HarnessKitScreenshots/ScreenshotConfig/padBezel``

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

The versioned bezel array for the iPad platform.

## Overview

`padBezel` holds one or more ``VersionedBezel`` entries that map iPadOS version ranges to the correct iPad hardware art. The transform pipeline uses ``ScreenshotConfig/matchedBezel(for:)`` to select the entry whose version range covers the screenshot's `osVersion`.

Include multiple entries when different iPadOS versions require different device frames -- for example, an iPad Air M4 bezel for iPadOS 17+ and a different model for earlier versions.

## See Also
- ``HarnessKitScreenshots/ScreenshotConfig``

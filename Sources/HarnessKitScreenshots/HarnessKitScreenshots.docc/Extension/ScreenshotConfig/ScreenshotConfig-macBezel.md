# ``HarnessKitScreenshots/ScreenshotConfig/macBezel``

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

The versioned bezel array for the macOS platform.

## Overview

`macBezel` holds one or more ``VersionedBezel`` entries that map macOS version ranges to the correct Mac hardware art. Each entry can include a `wallpaperType` to control the desktop wallpaper variant rendered inside the bezel behind the app window.

The transform pipeline uses ``ScreenshotConfig/matchedBezel(for:)`` to select the entry whose version range covers the screenshot's `osVersion`, then composites the screenshot onto the matched Mac laptop or desktop frame.

## See Also
- ``HarnessKitScreenshots/ScreenshotConfig``

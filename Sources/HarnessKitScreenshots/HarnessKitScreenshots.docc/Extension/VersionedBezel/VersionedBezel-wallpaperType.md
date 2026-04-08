# ``HarnessKitScreenshots/VersionedBezel/wallpaperType``

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

The macOS wallpaper variant rendered inside the bezel.

## Overview

`wallpaperType` is a string token such as `"Default"` or `"Custom"` that selects the desktop wallpaper image displayed behind the app window within the Mac device frame. The transform pipeline uses this value only for macOS screenshots.

The property defaults to `"Default"` and is ignored for non-macOS entries. When authoring macOS bezel entries, set this to a token that matches a wallpaper variant available in the bezel catalogue.

## See Also
- ``HarnessKitScreenshots/VersionedBezel``

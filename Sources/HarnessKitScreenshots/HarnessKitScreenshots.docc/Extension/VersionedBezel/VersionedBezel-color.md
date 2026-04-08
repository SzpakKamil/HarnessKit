# ``HarnessKitScreenshots/VersionedBezel/color``

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

The bezel color variant for this device entry.

## Overview

`color` is a string token such as `"Black"`, `"Silver"`, `"Blue"`, or `"JetBlack"` that selects the finish of the device frame. The transform pipeline combines ``deviceID`` and `color` to resolve the final bezel image from the catalogue.

For platforms where color is not meaningful -- such as tvOS -- use `"Default"`. The token must match a color variant that exists in the bezel catalogue for the given ``deviceID``.

## See Also
- ``HarnessKitScreenshots/VersionedBezel``

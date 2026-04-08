# ``HarnessKitScreenshots/VersionedBezel/band``

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

The watch band name for watchOS bezel entries.

## Overview

`band` is a string token such as `"SportBandBlack"` that identifies the Apple Watch band image rendered alongside the watch case. The transform pipeline uses this value only for watchOS screenshots -- it is combined with ``deviceID`` and ``color`` to load the complete watch frame.

For non-watchOS entries this property defaults to an empty string and is ignored by the pipeline. When authoring watchOS bezel entries, always provide a valid band token that exists in the bezel catalogue.

## See Also
- ``HarnessKitScreenshots/VersionedBezel``

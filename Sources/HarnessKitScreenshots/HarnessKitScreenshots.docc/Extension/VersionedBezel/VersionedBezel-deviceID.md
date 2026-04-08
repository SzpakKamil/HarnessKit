# ``HarnessKitScreenshots/VersionedBezel/deviceID``

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

The device descriptor ID used to resolve the bezel image.

## Overview

`deviceID` is a string token such as `"iPhone17"`, `"iPadAir11M4"`, or `"MacbookPro16M4"` that identifies the device model whose bezel art should be loaded. The transform pipeline combines this value with ``color`` (and ``band`` for watchOS) to locate the correct image assets in the bezel catalogue.

This ID does not include the color variant -- color is specified separately so that a single device model can support multiple finishes without duplicating entries.

## See Also
- ``HarnessKitScreenshots/VersionedBezel``

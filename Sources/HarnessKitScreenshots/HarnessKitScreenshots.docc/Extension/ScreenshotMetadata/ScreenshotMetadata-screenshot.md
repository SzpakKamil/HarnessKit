# ``HarnessKitScreenshots/ScreenshotMetadata/screenshot(from:)``

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

Decodes a ``Screenshot`` from an ImageIO properties dictionary.

## Overview

Expects a dictionary in the format returned by `CGImageSourceCopyPropertiesAtIndex(_:_:_:)`. The method looks up the `kCGImagePropertyPNGDictionary` key, extracts the JSON string from the `Description` field, and decodes it into a ``Screenshot``.

Returns `nil` if the dictionary does not contain valid screenshot metadata. For reading directly from a file on disk, use ``read(from:)`` instead.

## See Also
- ``HarnessKitScreenshots/ScreenshotMetadata/pngProperties(for:)``
- ``HarnessKitScreenshots/ScreenshotMetadata/read(from:)``

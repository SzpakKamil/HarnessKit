# ``HarnessKitScreenshots/ScreenshotMetadata/pngProperties(for:)``

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

Returns a PNG property dictionary containing the JSON-encoded screenshot.

## Overview

Encodes the given ``Screenshot`` as JSON with sorted keys and wraps it in an ImageIO-compatible properties dictionary keyed under `kCGImagePropertyPNGDictionary`. Pass the resulting dictionary to `CGImageDestinationAddImage(_:_:_:)` when writing a PNG file manually.

Returns an empty dictionary if encoding fails. For most use cases, prefer ``write(cgImage:screenshot:to:)`` which calls this method internally.

## See Also
- ``HarnessKitScreenshots/ScreenshotMetadata/screenshot(from:)``
- ``HarnessKitScreenshots/ScreenshotMetadata/write(cgImage:screenshot:to:)``

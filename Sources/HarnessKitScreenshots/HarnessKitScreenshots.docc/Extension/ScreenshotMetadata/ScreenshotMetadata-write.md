# ``HarnessKitScreenshots/ScreenshotMetadata/write(cgImage:screenshot:to:)``

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

Writes a `CGImage` as a PNG file with embedded ``Screenshot`` metadata.

## Overview

Creates a `CGImageDestination` at the given file URL, attaches the JSON-encoded ``Screenshot`` as PNG `tEXt` metadata via ``pngProperties(for:)``, and finalizes the image to disk. The resulting PNG file contains both the pixel data and the full screenshot configuration, so downstream tools can read it back with ``read(from:)``.

Throws a `CocoaError.fileWriteUnknown` if the destination cannot be created or if finalization fails.

## See Also
- ``HarnessKitScreenshots/ScreenshotMetadata/read(from:)``
- ``HarnessKitScreenshots/ScreenshotMetadata/pngProperties(for:)``

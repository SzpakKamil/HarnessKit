# ``HarnessKitScreenshots/ScreenshotMetadata/read(from:)``

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

Reads ``Screenshot`` metadata from a PNG file on disk.

## Overview

Opens the PNG at the given file URL using `CGImageSourceCreateWithURL`, extracts the image properties from the first image in the source, and decodes the embedded ``Screenshot`` JSON from the `tEXt` `Description` field.

Returns `nil` if the file cannot be read, is not a valid image source, or does not contain embedded screenshot metadata.

## See Also
- ``HarnessKitScreenshots/ScreenshotMetadata/write(cgImage:screenshot:to:)``
- ``HarnessKitScreenshots/ScreenshotMetadata/screenshot(from:)``

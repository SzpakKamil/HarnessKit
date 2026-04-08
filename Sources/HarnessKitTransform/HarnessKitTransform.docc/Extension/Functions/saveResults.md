# ``HarnessKitTransform/saveResults(image:screenshot:to:)``

@Metadata {
    @SupportedLanguage(swift)
    @Available(macOS, introduced: "11.0")
    @DocumentationExtension(mergeBehavior: override)
}
@Options {
    @AutomaticSeeAlso(disabled)
    @AutomaticArticleSubheading(disabled)
}

Saves the processed image as a PNG with embedded screenshot metadata.

## Overview

Creates the output directory if it does not exist, derives the filename from `Screenshot.prettyName()`, and writes the image as a PNG using `ScreenshotMetadata.write(cgImage:screenshot:to:)` to embed the `Screenshot` metadata in the file.

A second overload, `saveResults(image:name:to:)`, accepts a plain string name instead of a `Screenshot` value and writes a standard PNG without metadata.

### Parameters

| Name | Type | Description |
| :--- | :--- | :--- |
| `image` | `NSImage` | The processed image to save. |
| `screenshot` | `Screenshot` | Metadata embedded into the PNG and used to derive the filename. |
| `to` | `URL` | Directory where the PNG will be written. Created if needed. |

> Throws: ``TransformError`` if the directory cannot be created or the image cannot be converted to PNG.

## See Also

- ``transformScreenshot(image:screenshot:config:outputDirectory:)``
- ``processScreenshot(image:screenshot:config:)``

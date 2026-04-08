# ``HarnessKitTransform/transformScreenshot(image:screenshot:config:outputDirectory:)``

@Metadata {
    @SupportedLanguage(swift)
    @Available(macOS, introduced: "11.0")
    @DocumentationExtension(mergeBehavior: override)
}
@Options {
    @AutomaticSeeAlso(disabled)
    @AutomaticArticleSubheading(disabled)
}

Processes a screenshot through the full pipeline and saves the result to disk.

## Overview

This is the primary entry point for the transform pipeline. It delegates to ``processScreenshot(image:screenshot:config:)`` for image processing and then calls ``saveResults(image:screenshot:to:)`` to write the final PNG — with embedded `Screenshot` metadata — to `outputDirectory`.

### Parameters

| Name | Type | Description |
| :--- | :--- | :--- |
| `image` | `NSImage` | The raw screenshot image captured during testing. |
| `screenshot` | `Screenshot` | Metadata describing the screenshot (OS, appearance, crop, etc.). |
| `config` | `ScreenshotConfig` | Versioned bezel and resolution configuration. |
| `outputDirectory` | `URL` | Directory where the resulting PNG will be written. |

> Throws: ``TransformError`` if a required bezel is missing or saving fails.

## See Also

- ``processScreenshot(image:screenshot:config:)``
- ``saveResults(image:screenshot:to:)``

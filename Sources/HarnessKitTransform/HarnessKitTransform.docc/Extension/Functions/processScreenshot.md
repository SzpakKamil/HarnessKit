# ``HarnessKitTransform/processScreenshot(image:screenshot:config:)``

@Metadata {
    @SupportedLanguage(swift)
    @Available(macOS, introduced: "11.0")
    @DocumentationExtension(mergeBehavior: override)
}
@Options {
    @AutomaticSeeAlso(disabled)
    @AutomaticArticleSubheading(disabled)
}

Processes a screenshot through the platform-specific pipeline and returns the resulting image.

## Overview

Routes the raw screenshot to the correct platform handler based on `Screenshot.os` — macOS, iOS, iPadOS, watchOS, tvOS, or visionOS. Each platform handler builds a ``BezelPipelineParams`` value from the `Screenshot` and `ScreenshotConfig` metadata and calls ``applyBezelPipeline(image:params:)`` to produce the final image.

This function does not save the result to disk. Call ``saveResults(image:screenshot:to:)`` afterwards if persistence is needed, or use ``transformScreenshot(image:screenshot:config:outputDirectory:)`` for a single call that does both.

### Parameters

| Name | Type | Description |
| :--- | :--- | :--- |
| `image` | `NSImage` | The raw screenshot image captured during testing. |
| `screenshot` | `Screenshot` | Metadata describing the screenshot (OS, device, appearance, etc.). |
| `config` | `ScreenshotConfig` | Versioned bezel and resolution configuration. |

> Throws: ``TransformError`` if a required bezel is missing.

## See Also

- ``transformScreenshot(image:screenshot:config:outputDirectory:)``
- ``applyBezelPipeline(image:params:)``

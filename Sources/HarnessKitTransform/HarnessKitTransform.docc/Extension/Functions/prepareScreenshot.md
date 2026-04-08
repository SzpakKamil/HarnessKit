# ``HarnessKitTransform/prepareScreenshot(image:os:)``

@Metadata {
    @SupportedLanguage(swift)
    @Available(macOS, introduced: "11.0")
    @DocumentationExtension(mergeBehavior: override)
}
@Options {
    @AutomaticSeeAlso(disabled)
    @AutomaticArticleSubheading(disabled)
}

Prepares a raw screenshot for the bezel pipeline by applying platform-specific adjustments.

## Overview

Performs pre-processing that normalizes the screenshot before it enters the bezel pipeline. The behavior depends on the target OS:

- **macOS** — returns the image unchanged. The bezel handles positioning, and shadows use `ScreenshotShadow` entries.
- **iOS / iPadOS** — rotates landscape captures back to portrait orientation so subsequent pipeline steps always work with a portrait-oriented image.
- **All others** — returns the image unchanged.

This function is the first step inside ``applyBezelPipeline(image:params:)``.

### Parameters

| Name | Type | Description |
| :--- | :--- | :--- |
| `image` | `NSImage` | The raw screenshot image. |
| `os` | `TargetOS` | The platform the screenshot was captured on. |

## See Also

- ``applyBezelPipeline(image:params:)``
- ``maskScreenshot(image:cornerRadius:)``

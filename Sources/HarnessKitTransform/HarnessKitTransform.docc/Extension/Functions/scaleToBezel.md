# ``HarnessKitTransform/scaleToBezel(image:factor:)``

@Metadata {
    @SupportedLanguage(swift)
    @Available(macOS, introduced: "11.0")
    @DocumentationExtension(mergeBehavior: override)
}
@Options {
    @AutomaticSeeAlso(disabled)
    @AutomaticArticleSubheading(disabled)
}

Scales the screenshot by a uniform factor while preserving the canvas size.

## Overview

Draws the image at the given scale factor centered within a canvas that matches the original image dimensions. A factor of `1.0` returns the image unchanged. Values less than `1.0` shrink the screenshot toward the center, leaving transparent padding around the edges; values greater than `1.0` enlarge it, cropping the edges.

This step runs after ``maskScreenshot(image:cornerRadius:)`` and before ``placeBezel(image:bezel:verticalOffset:horizontalOffset:screenshotOnTop:scaleUpToFill:nativeScreenSize:)`` in the pipeline.

### Parameters

| Name | Type | Description |
| :--- | :--- | :--- |
| `image` | `NSImage` | The screenshot to scale. |
| `factor` | `CGFloat` | Uniform scale factor. `1.0` = no change. |

## See Also

- ``maskScreenshot(image:cornerRadius:)``
- ``placeBezel(image:bezel:verticalOffset:horizontalOffset:screenshotOnTop:scaleUpToFill:nativeScreenSize:)``

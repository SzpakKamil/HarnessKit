# ``HarnessKitTransform/maskScreenshot(image:cornerRadius:)``

@Metadata {
    @SupportedLanguage(swift)
    @Available(macOS, introduced: "11.0")
    @DocumentationExtension(mergeBehavior: override)
}
@Options {
    @AutomaticSeeAlso(disabled)
    @AutomaticArticleSubheading(disabled)
}

Clips the screenshot to a rounded rectangle.

## Overview

Applies a rounded-rectangle clipping mask to the image using the given corner radius in pixels. Pass `0` to skip clipping and return the original image unchanged.

The corner radius is typically derived from the ``BezelPipelineParams/cornerRadius`` fraction multiplied by the smaller image dimension, so it scales correctly across different device resolutions.

### Parameters

| Name | Type | Description |
| :--- | :--- | :--- |
| `image` | `NSImage` | The screenshot to mask. |
| `cornerRadius` | `CGFloat` | Corner radius in pixels. `0` skips clipping. |

## See Also

- ``prepareScreenshot(image:os:)``
- ``scaleToBezel(image:factor:)``

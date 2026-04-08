# ``HarnessKitTransform/applyOrientation(image:orientation:)``

@Metadata {
    @SupportedLanguage(swift)
    @Available(macOS, introduced: "11.0")
    @DocumentationExtension(mergeBehavior: override)
}
@Options {
    @AutomaticSeeAlso(disabled)
    @AutomaticArticleSubheading(disabled)
}

Rotates the device composition to the requested orientation.

## Overview

When `orientation` is `.landscape`, the image is rotated 90 degrees clockwise and the output dimensions are swapped (width becomes height and vice versa). For `.portrait` or any other value, the image is returned unchanged.

This step runs after ``placeBezel(image:bezel:verticalOffset:horizontalOffset:screenshotOnTop:scaleUpToFill:nativeScreenSize:)`` and before the composition is placed onto the resolution canvas inside ``applyBezelPipeline(image:params:)``.

### Parameters

| Name | Type | Description |
| :--- | :--- | :--- |
| `image` | `NSImage` | The device composition to rotate. |
| `orientation` | `ScreenOrientation` | The target orientation. |

## See Also

- ``placeBezel(image:bezel:verticalOffset:horizontalOffset:screenshotOnTop:scaleUpToFill:nativeScreenSize:)``
- ``applyBezelPipeline(image:params:)``

# ``HarnessKitTransform/applyOrientation(image:orientation:)``

@Metadata {
    @SupportedLanguage(swift)
    @Available(macOS, introduced: "11.0")
    @DocumentationExtension(mergeBehavior: override)
}

@Options {
    @AutomaticArticleSubheading(disabled)
}

Rotates a composed image for landscape output.

## Overview

`applyOrientation` is a no-op for `.portrait`. For `.landscape` it rotates the image 90° counterclockwise, swapping width and height in the process. The pipeline calls this step after bezel compositing and before adding the background color.

## Parameters

| Name | Type | Description |
| :--- | :--- | :--- |
| `image` | `NSImage` | The image to rotate. |
| `orientation` | `ScreenOrientation` | `.portrait` returns the image unchanged; `.landscape` rotates 90° CCW. |

## Returns

The rotated `NSImage`, or the original image if `orientation` is `.portrait`.

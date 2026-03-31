# ``HarnessKitTransform/adjustResolution(image:resolution:)``

@Metadata {
    @SupportedLanguage(swift)
    @Available(macOS, introduced: "11.0")
    @DocumentationExtension(mergeBehavior: override)
}

@Options {
    @AutomaticArticleSubheading(disabled)
}

Scales an image to fit the target resolution canvas.

## Overview

`adjustResolution` is the final sizing step in the pipeline. It scales `image` to fit inside the canvas defined by `resolution.size`, preserving aspect ratio and centering the result on a transparent background.

| Resolution | Canvas |
| :--- | :--- |
| `.default` | 603 × 416 pt |
| `.full` | 2089 × 1440 pt |

## Parameters

| Name | Type | Description |
| :--- | :--- | :--- |
| `image` | `NSImage` | The image to resize. |
| `resolution` | `ScreenshotResolution` | The target canvas size from `ScreenshotConfig.resolution`. |

## Returns

The image scaled to fit the resolution canvas, centered on a transparent background.

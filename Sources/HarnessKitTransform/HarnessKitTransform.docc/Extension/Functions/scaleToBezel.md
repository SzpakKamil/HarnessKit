# ``HarnessKitTransform/scaleToBezel(image:factor:)``

@Metadata {
    @SupportedLanguage(swift)
    @Available(macOS, introduced: "11.0")
    @DocumentationExtension(mergeBehavior: override)
}

@Options {
    @AutomaticArticleSubheading(disabled)
}

Shrinks a screenshot to fit inside a device bezel by applying a uniform scale factor.

## Overview

`scaleToBezel` multiplies the image's width and height by `factor` (typically `0.75`–`0.99`), draws the smaller result centered on a canvas that preserves the original size, and returns the padded image. The surrounding area is transparent, ready for `placeBezel` to composite the bezel art on top.

The scale factor comes from `BezelDescriptor.scale` and is calibrated so the screenshot aligns exactly with the display area in the bezel PNG.

## Parameters

| Name | Type | Description |
| :--- | :--- | :--- |
| `image` | `NSImage` | The screenshot to scale down. |
| `factor` | `CGFloat` | Uniform scale factor (0–1). Use `bezelCase.scale`. |

## Returns

An `NSImage` the same size as the input, with the screenshot scaled and centered on a transparent background.

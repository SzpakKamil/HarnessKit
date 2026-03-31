# ``HarnessKitTransform/placeBezel(image:bezel:verticalOffset:screenshotOnTop:)``

@Metadata {
    @SupportedLanguage(swift)
    @Available(macOS, introduced: "11.0")
    @DocumentationExtension(mergeBehavior: override)
}

@Options {
    @AutomaticArticleSubheading(disabled)
}

Composites a screenshot and a device bezel PNG into a single image.

## Overview

`placeBezel` fits the screenshot inside the bezel canvas using aspect-fit scaling, shifts it vertically by `verticalOffset` points, then composites the two layers. The `screenshotOnTop` parameter controls draw order:

- `false` — screenshot is drawn first, bezel on top. Use this for phones, iPads, Apple Watch, and Apple TV where the bezel frame sits in front of the screen.
- `true` — bezel is drawn first, screenshot on top. Use this for Mac laptops and iMacs where the screen content sits above the display cutout in the bezel image.

The output canvas matches the bezel PNG dimensions.

## Parameters

| Name | Type | Description |
| :--- | :--- | :--- |
| `image` | `NSImage` | The scaled screenshot (output of `scaleToBezel`). |
| `bezel` | `NSImage` | The bezel border image from `BezelDescriptor.borderImage`. |
| `verticalOffset` | `CGFloat` | Points to shift the screenshot vertically inside the bezel. Use `bezelCase.verticalOffset`. |
| `screenshotOnTop` | `Bool` | When `true` the screenshot is drawn above the bezel layer. Default: `false`. |

## Returns

The composited `NSImage` at the bezel's natural size.

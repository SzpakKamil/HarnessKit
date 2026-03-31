# ``HarnessKitTransform/prepareScreenshot(image:scaleMacOS:os:)``

@Metadata {
    @SupportedLanguage(swift)
    @Available(macOS, introduced: "11.0")
    @DocumentationExtension(mergeBehavior: override)
}

@Options {
    @AutomaticArticleSubheading(disabled)
}

Normalizes a screenshot image before bezel compositing.

## Overview

`prepareScreenshot` applies platform-specific preparation as the first pipeline step:

**macOS** — Scales the screenshot to fit inside a 3456 × 2168 pt canvas and adds a soft drop shadow (50 pt blur, 15% opacity) when the image is smaller than 90% of the canvas width. The shadow padding is added to the canvas size to prevent clipping.

**iOS and iPadOS** — Rotates landscape screenshots (width > height) 90° counterclockwise to portrait orientation. The transform pipeline expects portrait input; `applyOrientation` handles the final rotation for landscape output.

**All other platforms** — Returns the image unchanged.

## Parameters

| Name | Type | Description |
| :--- | :--- | :--- |
| `image` | `NSImage` | The raw screenshot to prepare. |
| `scaleMacOS` | `Bool` | On macOS, whether to scale the image to fit the base canvas. Default: `true`. Pass `false` when `addBezel` is `false` to skip scaling. |
| `os` | `TargetOS` | The target platform, used to choose the preparation branch. |

## Returns

The prepared `NSImage`.

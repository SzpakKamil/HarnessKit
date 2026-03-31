# ``HarnessKitTransform/maskScreenshot(image:bezel:)``

@Metadata {
    @SupportedLanguage(swift)
    @Available(macOS, introduced: "11.0")
    @DocumentationExtension(mergeBehavior: override)
}

@Options {
    @AutomaticArticleSubheading(disabled)
}

Clips a screenshot to the device's screen shape using a grayscale mask PNG.

## Overview

`maskScreenshot` loads the mask image for `bezel` via `bezel.maskImage()` and uses `CGImage.masking(_:)` to clip the screenshot. White pixels in the mask reveal the screenshot; black pixels cut it out. This removes rounded display corners and cutouts so the screenshot fits cleanly inside the bezel art.

The mask PNG must exist in the module bundle as `"\(bezel.shortID)Mask.png"`. If the mask cannot be loaded, the function returns the original image unchanged.

## Parameters

| Name | Type | Description |
| :--- | :--- | :--- |
| `image` | `NSImage` | The screenshot to mask. |
| `bezel` | `any BezelDescriptor` | The bezel whose mask shape to apply. |

## Returns

The masked `NSImage`, or the original image if the mask PNG is unavailable.

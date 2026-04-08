# ``HarnessKitTransform/addBackground(image:background:backgroundImageCache:)``

@Metadata {
    @SupportedLanguage(swift)
    @Available(macOS, introduced: "11.0")
    @DocumentationExtension(mergeBehavior: override)
}
@Options {
    @AutomaticSeeAlso(disabled)
    @AutomaticArticleSubheading(disabled)
}

Applies a background behind the given image.

## Overview

Draws the appropriate background based on the `ScreenshotBackground` variant:

- **`.solid(hex:)`** — fills the canvas with a single color parsed from a hex string.
- **`.gradient(startHex:endHex:angle:)`** — draws a two-stop linear gradient at the specified angle.
- **`.image(name:directory:scale:offsetX:offsetY:)`** — draws a background image with aspect-fill, optional scale, and offset. When a pre-loaded `backgroundImageCache` is provided, it is used directly instead of loading from disk.

If `background` is `nil`, the image is returned unchanged.

### Parameters

| Name | Type | Description |
| :--- | :--- | :--- |
| `image` | `NSImage` | The foreground image to place over the background. |
| `background` | `ScreenshotBackground?` | The background type and configuration. |
| `backgroundImageCache` | `NSImage?` | Optional pre-loaded background image, avoiding disk I/O. |

## See Also

- ``applyShadows(image:shadows:compositionSize:compositionCenter:)``
- ``cropImage(image:crop:)``

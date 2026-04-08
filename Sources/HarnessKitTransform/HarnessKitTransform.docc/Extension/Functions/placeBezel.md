# ``HarnessKitTransform/placeBezel(image:bezel:verticalOffset:horizontalOffset:screenshotOnTop:scaleUpToFill:nativeScreenSize:)``

@Metadata {
    @SupportedLanguage(swift)
    @Available(macOS, introduced: "11.0")
    @DocumentationExtension(mergeBehavior: override)
}
@Options {
    @AutomaticSeeAlso(disabled)
    @AutomaticArticleSubheading(disabled)
}

Places the screenshot inside the bezel frame image.

## Overview

Composites the screenshot and bezel onto a canvas whose size matches the bezel's pixel dimensions (via ``pixelSize(of:)``). The screenshot is aspect-fit into the bezel area, then offset by fractional vertical and horizontal values.

Layout uses pixel dimensions for DPI-independent sizing, while drawing uses `NSImage.size` for AppKit's coordinate system.

When `screenshotOnTop` is `false` (the default), the screenshot is drawn first and the bezel overlays it. When `true`, the bezel is drawn first and the screenshot overlays the frame — useful for bezels with transparent screen areas.

When `scaleUpToFill` is `false` and a `nativeScreenSize` is provided, the screenshot is placed at its natural pixel density relative to the device screen. If no native size is available, the screenshot falls back to 50% of the aspect-fit size for placeholder display.

### Parameters

| Name | Type | Description |
| :--- | :--- | :--- |
| `image` | `NSImage` | The prepared screenshot. |
| `bezel` | `NSImage` | The device bezel frame image. |
| `verticalOffset` | `CGFloat` | Fraction of bezel height to shift the screenshot vertically. |
| `horizontalOffset` | `CGFloat` | Fraction of bezel width to shift the screenshot horizontally. |
| `screenshotOnTop` | `Bool` | Whether the screenshot draws above the bezel. |
| `scaleUpToFill` | `Bool` | Whether to scale the screenshot to fill the bezel. |
| `nativeScreenSize` | `NSSize?` | Native screen resolution for natural-density placement. |

## See Also

- ``scaleToBezel(image:factor:)``
- ``applyOrientation(image:orientation:)``
- ``pixelSize(of:)``

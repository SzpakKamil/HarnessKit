# ``HarnessKitTransform/BezelPipelineParams/init(os:bezelImage:scale:verticalOffset:horizontalOffset:cornerRadius:screenshotOnTop:scaleUpToFill:orientation:background:backgroundImageCache:shadows:crop:resolution:positionScale:positionOffsetX:positionOffsetY:canvasPadding:nativeScreenSize:)``

@Metadata {
    @SupportedLanguage(swift)
    @Available(macOS, introduced: "11.0")
    @DocumentationExtension(mergeBehavior: override)
}
@Options {
    @AutomaticSeeAlso(disabled)
    @AutomaticArticleSubheading(disabled)
}

Creates a fully specified set of bezel pipeline parameters.

## Overview

This is the primary initializer for ``BezelPipelineParams``. It accepts every configurable value consumed by the bezel pipeline, with sensible defaults for optional and layout-related parameters. Use this initializer when you need full control over positioning, shadows, background, and canvas padding.

Most parameters beyond the first seven have defaults, so a minimal call only needs the device essentials: `os`, `bezelImage`, `scale`, offsets, `cornerRadius`, and `screenshotOnTop`.

### Parameters

| Name | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `os` | `TargetOS` | — | The target operating system for screenshot preparation. |
| `bezelImage` | `NSImage` | — | The device bezel overlay image. |
| `scale` | `CGFloat` | — | Scale factor applied to the screenshot before compositing. |
| `verticalOffset` | `CGFloat` | — | Vertical pixel offset of the screenshot inside the bezel. |
| `horizontalOffset` | `CGFloat` | — | Horizontal pixel offset of the screenshot inside the bezel. |
| `cornerRadius` | `CGFloat` | — | Normalized corner radius for the screenshot mask. |
| `screenshotOnTop` | `Bool` | — | Whether the screenshot draws above the bezel layer. |
| `scaleUpToFill` | `Bool` | `true` | Whether the screenshot scales up to fill the bezel frame. |
| `orientation` | `ScreenOrientation?` | `nil` | Optional rotation applied after compositing. |
| `background` | `ScreenshotBackground?` | `nil` | Background fill placed behind the composition. |
| `backgroundImageCache` | `NSImage?` | `nil` | Pre-loaded background image, if applicable. |
| `shadows` | `[ScreenshotShadow]` | `[]` | Shadow layers rendered behind the device composition. |
| `crop` | `CropRect?` | `nil` | Optional crop applied as the final pipeline step. |
| `resolution` | `ScreenshotResolution` | `.full` | The output canvas resolution. |
| `positionScale` | `CGFloat` | `1.0` | Additional scale when placing the composition on the canvas. |
| `positionOffsetX` | `CGFloat` | `0.0` | Normalized horizontal offset on the canvas. |
| `positionOffsetY` | `CGFloat` | `0.0` | Normalized vertical offset on the canvas. |
| `canvasPadding` | `CGFloat` | `0.0` | Normalized inset padding around the composition. |
| `nativeScreenSize` | `NSSize?` | `nil` | Native screen pixel size for precise placement. |

## See Also

- ``HarnessKitTransform/BezelPipelineParams``
- ``HarnessKitTransform/BezelPipelineParams/init(os:bezelImage:scale:verticalOffset:horizontalOffset:cornerRadius:screenshotOnTop:orientation:backgroundHex:crop:resolution:)``

# ``HarnessKitTransform/BezelPipelineParams/init(os:bezelImage:scale:verticalOffset:horizontalOffset:cornerRadius:screenshotOnTop:orientation:backgroundHex:crop:resolution:)``

@Metadata {
    @SupportedLanguage(swift)
    @Available(macOS, introduced: "11.0")
    @DocumentationExtension(mergeBehavior: override)
}
@Options {
    @AutomaticSeeAlso(disabled)
    @AutomaticArticleSubheading(disabled)
}

Creates bezel pipeline parameters from a hex background string for backward compatibility.

## Overview

This convenience initializer wraps a hex color string into a `.solid` `ScreenshotBackground` value, making it easy to migrate older call sites that passed a plain hex string instead of the richer `ScreenshotBackground` type. Shadows, canvas padding, position offsets, and `scaleUpToFill` are set to their default values and cannot be customized through this initializer.

If `backgroundHex` is `nil`, the ``background`` property is set to `nil` and no background fill is applied.

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
| `orientation` | `ScreenOrientation?` | `nil` | Optional rotation applied after compositing. |
| `backgroundHex` | `String?` | — | A hex color string (e.g. `"#FF0000"`) converted to `.solid`. |
| `crop` | `CropRect?` | `nil` | Optional crop applied as the final pipeline step. |
| `resolution` | `ScreenshotResolution` | `.full` | The output canvas resolution. |

## See Also

- ``HarnessKitTransform/BezelPipelineParams``
- ``HarnessKitTransform/BezelPipelineParams/init(os:bezelImage:scale:verticalOffset:horizontalOffset:cornerRadius:screenshotOnTop:scaleUpToFill:orientation:background:backgroundImageCache:shadows:crop:resolution:positionScale:positionOffsetX:positionOffsetY:canvasPadding:nativeScreenSize:)``

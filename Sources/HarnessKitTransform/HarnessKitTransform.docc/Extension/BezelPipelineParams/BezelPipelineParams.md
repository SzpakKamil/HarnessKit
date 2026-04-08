# ``HarnessKitTransform/BezelPipelineParams``

@Metadata {
    @SupportedLanguage(swift)
    @Available(macOS, introduced: "11.0")
    @DocumentationExtension(mergeBehavior: override)
}
@Options {
    @AutomaticSeeAlso(disabled)
    @AutomaticArticleSubheading(disabled)
}

A value type that bundles every parameter consumed by ``applyBezelPipeline(image:params:)``.

## Overview

``BezelPipelineParams`` decouples the bezel pipeline from any specific descriptor type, letting callers build the parameter set from a ``DeviceDescriptor``, a `VersionedBezel`, or any other source. Because all properties are `let` constants, instances are safe to pass across isolation boundaries and are marked `@unchecked Sendable`.

> Important: Instances must be created and consumed on the same thread or task. Do not share an instance across concurrent contexts after creation.

### Property Summary

| Name | Type | Description |
| :--- | :--- | :--- |
| ``os`` | `TargetOS` | The operating system the screenshot targets. |
| ``bezelImage`` | `NSImage` | The device bezel overlay image. |
| ``scale`` | `CGFloat` | Scale factor applied to the screenshot before compositing. |
| ``verticalOffset`` | `CGFloat` | Vertical pixel offset of the screenshot inside the bezel. |
| ``horizontalOffset`` | `CGFloat` | Horizontal pixel offset of the screenshot inside the bezel. |
| ``cornerRadius`` | `CGFloat` | Normalized corner radius applied to the screenshot mask. |
| ``screenshotOnTop`` | `Bool` | Whether the screenshot draws above the bezel layer. |
| ``scaleUpToFill`` | `Bool` | Whether the screenshot scales up to fill the bezel frame. |
| ``orientation`` | `ScreenOrientation?` | Optional rotation applied after compositing. |
| ``background`` | `ScreenshotBackground?` | Background fill placed behind the composition. |
| ``backgroundImageCache`` | `NSImage?` | Pre-loaded background image, if applicable. |
| ``shadows`` | `[ScreenshotShadow]` | Shadow layers rendered behind the device composition. |
| ``crop`` | `CropRect?` | Optional crop applied as the final pipeline step. |
| ``resolution`` | `ScreenshotResolution` | The output canvas resolution. |
| ``positionScale`` | `CGFloat` | Additional scale applied when placing the composition on the canvas. |
| ``positionOffsetX`` | `CGFloat` | Normalized horizontal offset on the canvas (-1...1). |
| ``positionOffsetY`` | `CGFloat` | Normalized vertical offset on the canvas (-1...1). |
| ``canvasPadding`` | `CGFloat` | Normalized inset padding around the composition on the canvas. |
| ``nativeScreenSize`` | `NSSize?` | The native screen pixel size, used for precise placement. |

## Topics

### Creating Parameters

- ``init(os:bezelImage:scale:verticalOffset:horizontalOffset:cornerRadius:screenshotOnTop:scaleUpToFill:orientation:background:backgroundImageCache:shadows:crop:resolution:positionScale:positionOffsetX:positionOffsetY:canvasPadding:nativeScreenSize:)``
- ``init(os:bezelImage:scale:verticalOffset:horizontalOffset:cornerRadius:screenshotOnTop:orientation:backgroundHex:crop:resolution:)``

### Device and Bezel

- ``os``
- ``bezelImage``
- ``scale``
- ``cornerRadius``
- ``nativeScreenSize``

### Screenshot Placement

- ``verticalOffset``
- ``horizontalOffset``
- ``screenshotOnTop``
- ``scaleUpToFill``
- ``orientation``

### Canvas Layout

- ``resolution``
- ``positionScale``
- ``positionOffsetX``
- ``positionOffsetY``
- ``canvasPadding``

### Appearance

- ``background``
- ``backgroundImageCache``
- ``shadows``
- ``crop``

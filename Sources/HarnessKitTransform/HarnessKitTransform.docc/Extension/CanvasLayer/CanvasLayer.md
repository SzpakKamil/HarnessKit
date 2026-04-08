# ``HarnessKitTransform/CanvasLayer``

@Metadata {
    @SupportedLanguage(swift)
    @Available(macOS, introduced: "11.0")
    @DocumentationExtension(mergeBehavior: override)
}
@Options {
    @AutomaticSeeAlso(disabled)
    @AutomaticArticleSubheading(disabled)
}

A single layer in a multi-device canvas composition.

## Overview

`CanvasLayer` describes a positioned, scaled device image that ``composeCanvas(layers:canvasSize:background:crop:)`` composites onto a shared canvas. Each layer carries a rendered device image together with fractional coordinates and a uniform scale factor that control its placement relative to the canvas center.

Coordinates use a normalized system where the origin is the canvas center:

| Axis | Value | Meaning |
| :--- | :--- | :--- |
| ``x`` | `0` | Horizontally centered |
| ``x`` | `-1` | Left edge of the canvas |
| ``x`` | `1` | Right edge of the canvas |
| ``y`` | `0` | Vertically centered |
| ``y`` | `1` | Top edge of the canvas |
| ``y`` | `-1` | Bottom edge of the canvas |

Layers are drawn in array order — index 0 at the back, last index on top.

> Important: Instances must be created and consumed on the same thread or task. Do not share across concurrent contexts after creation.

## Topics

### Creating a Layer

- ``init(image:x:y:scale:)``

### Properties

- ``image``
- ``x``
- ``y``
- ``scale``

### Related

- ``composeCanvas(layers:canvasSize:background:crop:)``

# ``HarnessKitTransform/CanvasLayer/scale``

@Metadata {
    @SupportedLanguage(swift)
    @Available(macOS, introduced: "11.0")
    @DocumentationExtension(mergeBehavior: override)
}
@Options {
    @AutomaticSeeAlso(disabled)
    @AutomaticArticleSubheading(disabled)
}

Uniform scale applied to the image before placement.

## Overview

A value of `1.0` draws the image at its natural pixel dimensions. Values less than `1.0` shrink the image; values greater than `1.0` enlarge it. The scale is applied uniformly to both width and height before the layer is positioned on the canvas.

## See Also

- ``CanvasLayer/image``
- ``CanvasLayer/x``
- ``CanvasLayer/y``

# ``HarnessKitTransform/CanvasLayer/image``

@Metadata {
    @SupportedLanguage(swift)
    @Available(macOS, introduced: "11.0")
    @DocumentationExtension(mergeBehavior: override)
}
@Options {
    @AutomaticSeeAlso(disabled)
    @AutomaticArticleSubheading(disabled)
}

The rendered device image for this layer.

## Overview

This is the fully processed device image — typically the output of ``applyBezelPipeline(image:params:)`` — that ``composeCanvas(layers:canvasSize:background:crop:)`` draws onto the shared canvas. The image is drawn at the size determined by its natural dimensions multiplied by ``scale``.

## See Also

- ``CanvasLayer``
- ``CanvasLayer/scale``

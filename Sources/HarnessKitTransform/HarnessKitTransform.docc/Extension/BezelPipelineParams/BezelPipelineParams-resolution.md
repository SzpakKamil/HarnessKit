# ``HarnessKitTransform/BezelPipelineParams/resolution``

@Metadata {
    @SupportedLanguage(swift)
    @Available(macOS, introduced: "11.0")
    @DocumentationExtension(mergeBehavior: override)
}
@Options {
    @AutomaticSeeAlso(disabled)
    @AutomaticArticleSubheading(disabled)
}

The output canvas resolution onto which the device composition is placed.

## Overview

``resolution`` defines the pixel dimensions of the canvas created in step 2 of the pipeline. The composited device image is scaled to fit within these dimensions (minus ``canvasPadding``), preserving its aspect ratio. The default value is `.full`, which uses the bezel image's native resolution.

This property also drives a resolution-aware optimization: when the bezel image is significantly larger than the output canvas, the pipeline pre-scales the bezel to reduce memory usage and compositing time.

## See Also

- ``HarnessKitTransform/BezelPipelineParams``

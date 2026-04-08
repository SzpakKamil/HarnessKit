# ``HarnessKitTransform/BezelPipelineParams/canvasPadding``

@Metadata {
    @SupportedLanguage(swift)
    @Available(macOS, introduced: "11.0")
    @DocumentationExtension(mergeBehavior: override)
}
@Options {
    @AutomaticSeeAlso(disabled)
    @AutomaticArticleSubheading(disabled)
}

A normalized inset that adds padding between the device composition and the canvas edges.

## Overview

``canvasPadding`` reduces the available area for the composition on the output canvas. The value is normalized: `0.0` (the default) uses the full canvas, while `0.1` would reserve 10 % of the canvas dimension on each side, effectively shrinking the fit region to 80 % of the canvas. The pipeline incorporates this value into the scale-to-fit calculation in step 2.

Use this property to ensure consistent breathing room around the device, especially when shadows extend beyond the composition bounds and would otherwise be clipped.

## See Also

- ``HarnessKitTransform/BezelPipelineParams``

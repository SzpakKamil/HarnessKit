# ``HarnessKitTransform/BezelPipelineParams/positionScale``

@Metadata {
    @SupportedLanguage(swift)
    @Available(macOS, introduced: "11.0")
    @DocumentationExtension(mergeBehavior: override)
}
@Options {
    @AutomaticSeeAlso(disabled)
    @AutomaticArticleSubheading(disabled)
}

An additional scale multiplier applied when placing the device composition on the output canvas.

## Overview

``positionScale`` is multiplied with the fit scale that the pipeline computes to place the composition within the ``resolution`` canvas. A value of `1.0` (the default) uses the natural fit size. Values greater than `1.0` enlarge the composition beyond its fitted size, while values less than `1.0` shrink it, leaving more empty space around the device.

This parameter works together with ``positionOffsetX`` and ``positionOffsetY`` to give callers fine-grained control over where and how large the device appears on the final canvas.

## See Also

- ``HarnessKitTransform/BezelPipelineParams``

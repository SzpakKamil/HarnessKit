# ``HarnessKitTransform/BezelPipelineParams/positionOffsetY``

@Metadata {
    @SupportedLanguage(swift)
    @Available(macOS, introduced: "11.0")
    @DocumentationExtension(mergeBehavior: override)
}
@Options {
    @AutomaticSeeAlso(disabled)
    @AutomaticArticleSubheading(disabled)
}

A normalized vertical offset that shifts the device composition on the output canvas.

## Overview

``positionOffsetY`` moves the composition up or down from the canvas center. The value is normalized: it is multiplied by half the canvas height to compute the actual pixel displacement. A value of `0.0` (the default) centers the composition vertically. Positive values shift it upward; negative values shift it downward.

Combined with ``positionOffsetX`` and ``positionScale``, this property enables flexible multi-device layouts and off-center placements on a single canvas.

## See Also

- ``HarnessKitTransform/BezelPipelineParams``

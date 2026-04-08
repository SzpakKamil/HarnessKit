# ``HarnessKitTransform/BezelPipelineParams/positionOffsetX``

@Metadata {
    @SupportedLanguage(swift)
    @Available(macOS, introduced: "11.0")
    @DocumentationExtension(mergeBehavior: override)
}
@Options {
    @AutomaticSeeAlso(disabled)
    @AutomaticArticleSubheading(disabled)
}

A normalized horizontal offset that shifts the device composition on the output canvas.

## Overview

``positionOffsetX`` moves the composition left or right from the canvas center. The value is normalized: it is multiplied by half the canvas width to compute the actual pixel displacement. A value of `0.0` (the default) centers the composition horizontally. Positive values shift it to the right; negative values shift it to the left.

Combined with ``positionOffsetY`` and ``positionScale``, this property enables flexible multi-device layouts and off-center placements on a single canvas.

## See Also

- ``HarnessKitTransform/BezelPipelineParams``

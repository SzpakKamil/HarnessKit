# ``HarnessKitTransform/BezelPipelineParams/crop``

@Metadata {
    @SupportedLanguage(swift)
    @Available(macOS, introduced: "11.0")
    @DocumentationExtension(mergeBehavior: override)
}
@Options {
    @AutomaticSeeAlso(disabled)
    @AutomaticArticleSubheading(disabled)
}

An optional crop rectangle applied as the final step of the bezel pipeline.

## Overview

When ``crop`` is non-`nil`, the pipeline crops the finished image — after compositing, shadow rendering, and background application — to the region specified by the `CropRect` value. This is useful for trimming excess canvas area or focusing on a specific portion of the output.

When `nil`, the output retains the full canvas dimensions defined by ``resolution``.

## See Also

- ``HarnessKitTransform/BezelPipelineParams``

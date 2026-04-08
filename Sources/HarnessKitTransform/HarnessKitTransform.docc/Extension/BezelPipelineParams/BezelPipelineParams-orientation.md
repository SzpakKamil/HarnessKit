# ``HarnessKitTransform/BezelPipelineParams/orientation``

@Metadata {
    @SupportedLanguage(swift)
    @Available(macOS, introduced: "11.0")
    @DocumentationExtension(mergeBehavior: override)
}
@Options {
    @AutomaticSeeAlso(disabled)
    @AutomaticArticleSubheading(disabled)
}

An optional rotation applied to the device composition after the screenshot and bezel are merged.

## Overview

When ``orientation`` is non-`nil`, the pipeline rotates the composited device image to match the specified `ScreenOrientation`. The rotation happens after the screenshot has been placed inside the bezel but before the composition is placed onto the output canvas. This allows landscape and upside-down presentations without requiring separate bezel artwork for each orientation.

When `nil`, no rotation is applied and the composition retains its natural orientation.

## See Also

- ``HarnessKitTransform/BezelPipelineParams``

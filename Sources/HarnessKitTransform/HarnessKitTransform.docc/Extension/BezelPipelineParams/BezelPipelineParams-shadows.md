# ``HarnessKitTransform/BezelPipelineParams/shadows``

@Metadata {
    @SupportedLanguage(swift)
    @Available(macOS, introduced: "11.0")
    @DocumentationExtension(mergeBehavior: override)
}
@Options {
    @AutomaticSeeAlso(disabled)
    @AutomaticArticleSubheading(disabled)
}

The shadow layers rendered behind the device composition on the output canvas.

## Overview

``shadows`` provides an array of `ScreenshotShadow` values that are drawn relative to the fitted composition's size and center point. Multiple shadows can be stacked to create complex depth effects. The pipeline applies shadows in step 3, after the composition has been placed on the resolution canvas but before the background fill.

These are bezel shadows that give the device composition a sense of depth on the canvas. They are distinct from macOS window shadows, which are a separate system.

When the array is empty (the default), no shadow processing occurs.

## See Also

- ``HarnessKitTransform/BezelPipelineParams``

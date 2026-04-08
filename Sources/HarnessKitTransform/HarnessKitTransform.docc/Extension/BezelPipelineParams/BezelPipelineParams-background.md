# ``HarnessKitTransform/BezelPipelineParams/background``

@Metadata {
    @SupportedLanguage(swift)
    @Available(macOS, introduced: "11.0")
    @DocumentationExtension(mergeBehavior: override)
}
@Options {
    @AutomaticSeeAlso(disabled)
    @AutomaticArticleSubheading(disabled)
}

The background fill placed behind the entire composition on the output canvas.

## Overview

``background`` defines what appears behind the device composition and its shadows. It accepts a `ScreenshotBackground` value, which can represent a solid color, a gradient, an image, or other fill types supported by the screenshots module. The background is applied in step 4 of the pipeline, after shadows have been rendered.

When `nil`, the canvas area outside the device composition remains transparent.

## See Also

- ``HarnessKitTransform/BezelPipelineParams``

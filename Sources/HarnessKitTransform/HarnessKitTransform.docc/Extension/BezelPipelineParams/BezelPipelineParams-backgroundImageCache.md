# ``HarnessKitTransform/BezelPipelineParams/backgroundImageCache``

@Metadata {
    @SupportedLanguage(swift)
    @Available(macOS, introduced: "11.0")
    @DocumentationExtension(mergeBehavior: override)
}
@Options {
    @AutomaticSeeAlso(disabled)
    @AutomaticArticleSubheading(disabled)
}

A pre-loaded background image passed to the pipeline to avoid redundant disk reads.

## Overview

When ``background`` specifies an image-based fill, the caller can supply the already-loaded `NSImage` through ``backgroundImageCache``. The pipeline forwards this cached image to the background compositing step, skipping the file load that would otherwise occur on every invocation.

When `nil`, the pipeline loads the background image from the path specified in ``background`` (if applicable). For non-image backgrounds such as solid colors or gradients, this property is ignored.

## See Also

- ``HarnessKitTransform/BezelPipelineParams``

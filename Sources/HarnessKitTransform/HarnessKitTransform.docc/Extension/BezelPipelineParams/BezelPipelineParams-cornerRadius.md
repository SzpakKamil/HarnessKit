# ``HarnessKitTransform/BezelPipelineParams/cornerRadius``

@Metadata {
    @SupportedLanguage(swift)
    @Available(macOS, introduced: "11.0")
    @DocumentationExtension(mergeBehavior: override)
}
@Options {
    @AutomaticSeeAlso(disabled)
    @AutomaticArticleSubheading(disabled)
}

The normalized corner radius applied to the screenshot mask before compositing.

## Overview

``cornerRadius`` defines how rounded the screenshot's corners are. The value is normalized: the pipeline multiplies it by the smaller dimension of the prepared screenshot to compute the actual pixel radius. A value of `0` skips masking entirely, while typical device values produce the rounded-rectangle shape matching the physical display.

Corner masking is applied after OS-specific preparation but before scaling and bezel compositing.

## See Also

- ``HarnessKitTransform/BezelPipelineParams``

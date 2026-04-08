# ``HarnessKitTransform/BezelPipelineParams/scaleUpToFill``

@Metadata {
    @SupportedLanguage(swift)
    @Available(macOS, introduced: "11.0")
    @DocumentationExtension(mergeBehavior: override)
}
@Options {
    @AutomaticSeeAlso(disabled)
    @AutomaticArticleSubheading(disabled)
}

Whether the screenshot scales up to fill the bezel frame when it is smaller than the bezel's display area.

## Overview

When ``scaleUpToFill`` is `true` (the default), a screenshot that is smaller than the bezel's display area is scaled up so it completely fills the frame. When `false`, the screenshot retains its original size and is centered within the bezel, potentially leaving visible gaps around the edges.

This property is useful for bezels whose display area is larger than the screenshot's native resolution, ensuring no letterboxing appears in the final composition.

## See Also

- ``HarnessKitTransform/BezelPipelineParams``

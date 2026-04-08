# ``HarnessKitTransform/BezelPipelineParams/bezelImage``

@Metadata {
    @SupportedLanguage(swift)
    @Available(macOS, introduced: "11.0")
    @DocumentationExtension(mergeBehavior: override)
}
@Options {
    @AutomaticSeeAlso(disabled)
    @AutomaticArticleSubheading(disabled)
}

The device bezel overlay image composited with the screenshot.

## Overview

``bezelImage`` provides the frame artwork that surrounds the screenshot, such as an iPhone or Mac enclosure. The pipeline composites the screenshot and bezel at the bezel's native pixel resolution, drawing one on top of the other according to ``screenshotOnTop``.

When the bezel image is significantly larger than the output ``resolution``, the pipeline automatically downscales it before compositing to avoid unnecessary memory usage and drawing overhead.

## See Also

- ``HarnessKitTransform/BezelPipelineParams``

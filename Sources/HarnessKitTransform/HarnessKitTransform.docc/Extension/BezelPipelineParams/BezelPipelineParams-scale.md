# ``HarnessKitTransform/BezelPipelineParams/scale``

@Metadata {
    @SupportedLanguage(swift)
    @Available(macOS, introduced: "11.0")
    @DocumentationExtension(mergeBehavior: override)
}
@Options {
    @AutomaticSeeAlso(disabled)
    @AutomaticArticleSubheading(disabled)
}

The scale factor applied to the screenshot before it is composited with the bezel.

## Overview

``scale`` controls how the screenshot is sized relative to the bezel image. A value of `1.0` means the screenshot keeps its original pixel dimensions; values less than `1.0` shrink it, and values greater than `1.0` enlarge it. The scaling happens early in the pipeline, before the screenshot is placed inside the bezel frame.

This factor is typically derived from a ``DeviceDescriptor`` to ensure the screenshot fits the bezel artwork at the correct proportion.

## See Also

- ``HarnessKitTransform/BezelPipelineParams``

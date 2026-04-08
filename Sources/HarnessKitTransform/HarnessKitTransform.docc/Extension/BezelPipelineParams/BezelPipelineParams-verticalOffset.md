# ``HarnessKitTransform/BezelPipelineParams/verticalOffset``

@Metadata {
    @SupportedLanguage(swift)
    @Available(macOS, introduced: "11.0")
    @DocumentationExtension(mergeBehavior: override)
}
@Options {
    @AutomaticSeeAlso(disabled)
    @AutomaticArticleSubheading(disabled)
}

The vertical pixel offset of the screenshot inside the bezel frame.

## Overview

``verticalOffset`` shifts the screenshot up or down within the bezel artwork to align the screen content with the visible display area. The offset is specified in the bezel image's native pixel coordinate space and is applied during the compositing step.

Together with ``horizontalOffset``, this value ensures the screenshot is precisely positioned behind the bezel's screen cutout.

## See Also

- ``HarnessKitTransform/BezelPipelineParams``

# ``HarnessKitTransform/BezelPipelineParams/screenshotOnTop``

@Metadata {
    @SupportedLanguage(swift)
    @Available(macOS, introduced: "11.0")
    @DocumentationExtension(mergeBehavior: override)
}
@Options {
    @AutomaticSeeAlso(disabled)
    @AutomaticArticleSubheading(disabled)
}

Whether the screenshot draws above the bezel layer during compositing.

## Overview

When ``screenshotOnTop`` is `true`, the screenshot is drawn over the bezel image. When `false`, the bezel is drawn on top, which is the typical arrangement for devices where the bezel artwork includes transparent areas that reveal the screenshot underneath.

The correct value depends on the bezel artwork. Most phone and tablet bezels expect `false` so the frame covers the screenshot edges, while some display-only bezels may require `true`.

## See Also

- ``HarnessKitTransform/BezelPipelineParams``

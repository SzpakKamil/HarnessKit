# ``HarnessKitTransform/CanvasLayer/y``

@Metadata {
    @SupportedLanguage(swift)
    @Available(macOS, introduced: "11.0")
    @DocumentationExtension(mergeBehavior: override)
}
@Options {
    @AutomaticSeeAlso(disabled)
    @AutomaticArticleSubheading(disabled)
}

Vertical offset from the canvas center.

## Overview

The value is a fraction of half the canvas height. `0` places the image at the vertical center, `1` shifts it to the top edge, and `-1` shifts it to the bottom edge. Values outside the `-1...1` range are valid and push the image beyond the canvas bounds.

## See Also

- ``CanvasLayer/x``
- ``CanvasLayer/scale``

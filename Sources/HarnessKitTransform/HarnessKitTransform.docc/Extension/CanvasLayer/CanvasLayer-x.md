# ``HarnessKitTransform/CanvasLayer/x``

@Metadata {
    @SupportedLanguage(swift)
    @Available(macOS, introduced: "11.0")
    @DocumentationExtension(mergeBehavior: override)
}
@Options {
    @AutomaticSeeAlso(disabled)
    @AutomaticArticleSubheading(disabled)
}

Horizontal offset from the canvas center.

## Overview

The value is a fraction of half the canvas width. `0` places the image at the horizontal center, `-1` shifts it to the left edge, and `1` shifts it to the right edge. Values outside the `-1...1` range are valid and push the image beyond the canvas bounds.

## See Also

- ``CanvasLayer/y``
- ``CanvasLayer/scale``

# ``HarnessKitTransform/BezelPipelineParams/nativeScreenSize``

@Metadata {
    @SupportedLanguage(swift)
    @Available(macOS, introduced: "11.0")
    @DocumentationExtension(mergeBehavior: override)
}
@Options {
    @AutomaticSeeAlso(disabled)
    @AutomaticArticleSubheading(disabled)
}

The native screen pixel size of the target device, used for precise screenshot placement within the bezel.

## Overview

When ``nativeScreenSize`` is non-`nil`, the pipeline uses it to calculate exact placement of the screenshot inside the bezel frame, ensuring pixel-perfect alignment with the device's physical display area. This is particularly useful when the bezel artwork and the screenshot have different native resolutions.

When `nil`, the pipeline relies on the ``scale``, ``verticalOffset``, and ``horizontalOffset`` values alone to position the screenshot, which is sufficient for most standard device bezels.

## See Also

- ``HarnessKitTransform/BezelPipelineParams``

# ``HarnessKitTransform/BezelPipelineParams/os``

@Metadata {
    @SupportedLanguage(swift)
    @Available(macOS, introduced: "11.0")
    @DocumentationExtension(mergeBehavior: override)
}
@Options {
    @AutomaticSeeAlso(disabled)
    @AutomaticArticleSubheading(disabled)
}

The target operating system the screenshot was captured on.

## Overview

The pipeline uses ``os`` during the screenshot preparation step to apply OS-specific adjustments. For example, macOS screenshots may receive different masking or scaling treatment than iOS screenshots. This value is passed directly to the internal `prepareScreenshot` function at the start of ``applyBezelPipeline(image:params:)``.

The value is typically sourced from a `Screenshot` configuration or a ``DeviceDescriptor``.

## See Also

- ``HarnessKitTransform/BezelPipelineParams``

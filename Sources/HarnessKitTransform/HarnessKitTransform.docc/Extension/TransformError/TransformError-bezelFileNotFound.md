# ``HarnessKitTransform/TransformError/bezelFileNotFound(id:color:)``

@Metadata {
    @SupportedLanguage(swift)
    @Available(macOS, introduced: "11.0")
    @DocumentationExtension(mergeBehavior: override)
}

@Options {
    @AutomaticSeeAlso(disabled)
    @AutomaticArticleSubheading(disabled)
}

A bezel PNG file was not found in the object cache or the SPM bundle.

## Overview

Thrown when the transform pipeline resolves a bezel by device `id` and `color` but the corresponding PNG file is absent from both the content-addressed object cache and the fallback bundle shipped with the package.

Ensure ``HarnessKitCatalogue/prefetch(for:)`` has been called with a `ScreenshotConfig` that covers this device and color combination. If the bezel was recently added to the remote catalogue, call ``HarnessKitCatalogue/refresh()`` first to pick up the latest manifest.

## See Also

- ``bezelNotFound(screenshotID:)``
- ``bezelImageMissing(bezelID:)``

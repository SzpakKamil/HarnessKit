# ``HarnessKitTransform/TransformError/bezelImageMissing(bezelID:)``

@Metadata {
    @SupportedLanguage(swift)
    @Available(macOS, introduced: "11.0")
    @DocumentationExtension(mergeBehavior: override)
}

@Options {
    @AutomaticSeeAlso(disabled)
    @AutomaticArticleSubheading(disabled)
}

The bezel entry exists but its PNG image could not be loaded.

## Overview

Thrown when a matching bezel record is found in the catalogue but the corresponding image data is missing or corrupt. The associated `bezelID` identifies the bezel that failed to load.

This typically indicates a partially completed prefetch or a corrupted object-cache entry. Re-running ``HarnessKitCatalogue/refresh()`` followed by ``HarnessKitCatalogue/prefetch(for:)`` usually resolves the issue.

## See Also

- ``bezelNotFound(screenshotID:)``
- ``bezelFileNotFound(id:color:)``

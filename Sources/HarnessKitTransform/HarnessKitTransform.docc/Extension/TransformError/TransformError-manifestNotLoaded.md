# ``HarnessKitTransform/TransformError/manifestNotLoaded``

@Metadata {
    @SupportedLanguage(swift)
    @Available(macOS, introduced: "11.0")
    @DocumentationExtension(mergeBehavior: override)
}

@Options {
    @AutomaticSeeAlso(disabled)
    @AutomaticArticleSubheading(disabled)
}

No manifest has been loaded.

## Overview

Thrown when a catalogue operation requires a manifest but none is available. This means ``HarnessKitCatalogue/refresh()`` has either not been called yet or failed on its last attempt, and no previously cached manifest exists on disk.

Call ``HarnessKitCatalogue/refresh()`` before performing any prefetch or descriptor-lookup operations.

## See Also

- ``notInManifest(paths:)``

# ``HarnessKitTransform/HarnessKitCatalogue/evictStaleCache()``

@Metadata {
    @SupportedLanguage(swift)
    @Available(macOS, introduced: "11.0")
    @DocumentationExtension(mergeBehavior: override)
}

@Options {
    @AutomaticSeeAlso(disabled)
    @AutomaticArticleSubheading(disabled)
}

Removes cached objects that are no longer referenced by the current manifest.

## Overview

`evictStaleCache()` walks the on-disk object cache and deletes any content-addressed files whose SHA-256 hash does not appear in the loaded manifest. This reclaims disk space after a manifest update introduces new asset versions and the old ones are no longer needed.

Safe to call at any time. If no manifest is loaded, the method is a no-op.

``refresh()`` calls this automatically after installing a new manifest, so you typically only need to call it directly if you want to trigger eviction at a different point in your workflow.

## See Also

- ``invalidateCaches()``
- ``refresh()``

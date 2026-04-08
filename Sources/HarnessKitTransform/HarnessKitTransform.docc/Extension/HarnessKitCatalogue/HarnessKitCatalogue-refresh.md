# ``HarnessKitTransform/HarnessKitCatalogue/refresh()``

@Metadata {
    @SupportedLanguage(swift)
    @Available(macOS, introduced: "11.0")
    @DocumentationExtension(mergeBehavior: override)
}

@Options {
    @AutomaticSeeAlso(disabled)
    @AutomaticArticleSubheading(disabled)
}

Fetches the remote manifest, downloads catalogue JSONs, and evicts stale cached objects.

## Overview

`refresh()` performs three steps in order:

1. Downloads `manifest.json` from ``baseURL`` and validates its schema version against the client's supported version.
2. Persists the manifest to disk and downloads every catalogue JSON (`catalogue/*.json`) so that ``DeviceDescriptor`` lookups can proceed synchronously.
3. Calls ``evictStaleCache()`` to remove objects that are no longer referenced by the new manifest.

This method does **not** download any bezel PNGs. Call ``prefetch(for:)`` after refreshing to download the images your `ScreenshotConfig` requires.

If the network request fails, the error propagates to the caller. Any previously cached manifest remains available for offline fallback.

```swift
try await HarnessKitCatalogue.shared.refresh()
```

## See Also

- ``prefetch(for:)``
- ``prefetchAll()``
- ``evictStaleCache()``

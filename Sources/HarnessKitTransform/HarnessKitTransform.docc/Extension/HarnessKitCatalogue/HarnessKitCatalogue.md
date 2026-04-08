# ``HarnessKitTransform/HarnessKitCatalogue``

@Metadata {
    @SupportedLanguage(swift)
    @Available(macOS, introduced: "11.0")
    @DocumentationExtension(mergeBehavior: override)
}

@Options {
    @AutomaticSeeAlso(disabled)
    @AutomaticArticleSubheading(disabled)
}

An actor that manages remote bezel and device-descriptor assets hosted on Cloudflare R2.

## Overview

``HarnessKitCatalogue`` is the public entry point for downloading and caching the bezel PNGs and device-descriptor JSONs that the transform pipeline needs to composite screenshots. Access it through the ``shared`` singleton and follow a three-step pattern: refresh the manifest, prefetch the assets your `ScreenshotConfig` requires, then run the synchronous transform functions.

```swift
try await HarnessKitCatalogue.shared.refresh()             // fetch manifest + catalogue JSONs
try await HarnessKitCatalogue.shared.prefetch(for: config)  // download needed bezels
// now call processScreenshotMacOS / processScreenshotIOS / ... synchronously.
```

If the network is unreachable, ``refresh()`` is a no-op when a previously cached manifest exists, and descriptor lookups transparently fall back to the bundled baseline that ships with the SPM package.

All downloads are content-addressed (SHA-256) and deduplicated by the object cache, so calling ``prefetch(for:)`` repeatedly is safe and cheap.

### Cache Lifecycle

| Step | Method | Effect |
| :--- | :----- | :----- |
| 1 | ``refresh()`` | Downloads `manifest.json` and catalogue JSONs; evicts stale objects. |
| 2 | ``prefetch(for:)`` or ``prefetchAll()`` | Downloads bezel PNGs referenced by the config or the entire manifest. |
| 3 | ``invalidateCaches()`` | Bumps the generation counter so synchronous lookups see freshly downloaded bezels. |
| 4 | ``evictStaleCache()`` | Removes cached objects no longer referenced by the current manifest. |

## Topics

### Accessing the Catalogue

- ``shared``
- ``baseURL``

### Refreshing the Manifest

- ``refresh()``

### Prefetching Assets

- ``prefetch(for:)``
- ``prefetchAll()``

### Cache Management

- ``invalidateCaches()``
- ``evictStaleCache()``

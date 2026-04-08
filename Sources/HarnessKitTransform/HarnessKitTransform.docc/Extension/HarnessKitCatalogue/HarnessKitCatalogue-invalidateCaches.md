# ``HarnessKitTransform/HarnessKitCatalogue/invalidateCaches()``

@Metadata {
    @SupportedLanguage(swift)
    @Available(macOS, introduced: "11.0")
    @DocumentationExtension(mergeBehavior: override)
}

@Options {
    @AutomaticSeeAlso(disabled)
    @AutomaticArticleSubheading(disabled)
}

Bumps the generation counter so all cached indexes rebuild on next access.

## Overview

Call `invalidateCaches()` after ``prefetch(for:)`` when you need freshly downloaded bezels to be visible to synchronous `bezelImage()` lookups immediately. The method increments the internal generation counter in the catalogue store, forcing device-descriptor and bezel-index caches to rebuild the next time they are accessed.

This is a lightweight, synchronous operation that does not perform any I/O.

```swift
try await HarnessKitCatalogue.shared.prefetch(for: config)
await HarnessKitCatalogue.shared.invalidateCaches()
```

## See Also

- ``evictStaleCache()``
- ``prefetch(for:)``

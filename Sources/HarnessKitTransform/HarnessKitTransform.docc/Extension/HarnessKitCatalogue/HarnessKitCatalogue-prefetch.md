# ``HarnessKitTransform/HarnessKitCatalogue/prefetch(for:)``

@Metadata {
    @SupportedLanguage(swift)
    @Available(macOS, introduced: "11.0")
    @DocumentationExtension(mergeBehavior: override)
}

@Options {
    @AutomaticSeeAlso(disabled)
    @AutomaticArticleSubheading(disabled)
}

Downloads every bezel referenced by a `ScreenshotConfig`.

## Overview

`prefetch(for:)` inspects all `VersionedBezel` entries in the provided `ScreenshotConfig` -- Mac, phone, pad, TV, watch, and vision -- and determines the set of bezel PNG paths required. Files already present in the content-addressed object cache are skipped, so calling this method repeatedly is safe and cheap.

If any required paths are missing from the loaded manifest, the method throws ``TransformError/notInManifest(paths:)`` after attempting all other downloads.

If no manifest has been loaded yet (cold start before ``refresh()``), the method returns immediately and the transform pipeline falls back to bundled assets.

```swift
try await HarnessKitCatalogue.shared.prefetch(for: config)
```

## See Also

- ``refresh()``
- ``prefetchAll()``
- ``invalidateCaches()``

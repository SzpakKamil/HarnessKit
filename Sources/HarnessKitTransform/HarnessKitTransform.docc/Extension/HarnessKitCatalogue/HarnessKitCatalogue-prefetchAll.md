# ``HarnessKitTransform/HarnessKitCatalogue/prefetchAll()``

@Metadata {
    @SupportedLanguage(swift)
    @Available(macOS, introduced: "11.0")
    @DocumentationExtension(mergeBehavior: override)
}

@Options {
    @AutomaticSeeAlso(disabled)
    @AutomaticArticleSubheading(disabled)
}

Downloads every file listed in the current manifest.

## Overview

Use `prefetchAll()` in CI or tester environments where you want to warm the entire object cache in one shot, rather than downloading assets incrementally per-config. This ensures all subsequent transform calls can proceed without network access.

If no manifest has been loaded, the method returns immediately.

```swift
try await HarnessKitCatalogue.shared.refresh()
try await HarnessKitCatalogue.shared.prefetchAll()
```

## See Also

- ``prefetch(for:)``
- ``refresh()``

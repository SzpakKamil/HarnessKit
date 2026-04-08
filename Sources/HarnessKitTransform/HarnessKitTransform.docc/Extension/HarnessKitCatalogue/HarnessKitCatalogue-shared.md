# ``HarnessKitTransform/HarnessKitCatalogue/shared``

@Metadata {
    @SupportedLanguage(swift)
    @Available(macOS, introduced: "11.0")
    @DocumentationExtension(mergeBehavior: override)
}

@Options {
    @AutomaticSeeAlso(disabled)
    @AutomaticArticleSubheading(disabled)
}

The shared singleton instance of ``HarnessKitCatalogue``.

## Overview

Use `shared` to access the catalogue from anywhere in your test runner or CI driver. The instance is created lazily on first access and rehydrates any manifest written to disk by a previous session, so descriptor lookups can succeed even before ``refresh()`` is called.

```swift
let catalogue = HarnessKitCatalogue.shared
try await catalogue.refresh()
```

Because ``HarnessKitCatalogue`` is an actor, all calls through this property are automatically isolated.

## See Also

- ``baseURL``

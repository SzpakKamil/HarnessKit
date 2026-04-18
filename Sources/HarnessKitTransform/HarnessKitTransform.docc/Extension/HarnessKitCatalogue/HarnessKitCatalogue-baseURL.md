# ``HarnessKitTransform/HarnessKitCatalogue/baseURL``

@Metadata {
    @SupportedLanguage(swift)
    @Available(macOS, introduced: "11.0")
    @DocumentationExtension(mergeBehavior: override)
}

@Options {
    @AutomaticSeeAlso(disabled)
    @AutomaticArticleSubheading(disabled)
}

The base URL for all remote asset downloads.

## Overview

`baseURL` defaults to the production Cloudflare R2 custom domain. It is read-only; configure it via ``configureBaseURL(_:)``:

```swift
HarnessKitCatalogue.configureBaseURL(URL(string: "https://staging-assets.example.com")!)
```

`configureBaseURL(_:)` is `nonisolated` and thread-safe — backed by an `os_unfair_lock` so concurrent reads and writes are race-free. Call it once at app or test-runner launch before the first call to ``refresh()``.

## See Also

- ``shared``

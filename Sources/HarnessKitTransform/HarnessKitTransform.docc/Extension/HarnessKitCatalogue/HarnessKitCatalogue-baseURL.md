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

`baseURL` defaults to the production Cloudflare R2 custom domain. Override it once at app or test-runner launch to point at a staging bucket or a local server:

```swift
HarnessKitCatalogue.baseURL = URL(string: "https://staging-assets.example.com")!
```

This property is declared `nonisolated(unsafe)` so it can be set from any isolation context before any actor-isolated work begins. Set it exactly once before the first call to ``refresh()``; changing it after downloads have started is unsupported.

## See Also

- ``shared``

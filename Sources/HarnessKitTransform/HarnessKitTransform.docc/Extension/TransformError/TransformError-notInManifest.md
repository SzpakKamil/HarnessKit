# ``HarnessKitTransform/TransformError/notInManifest(paths:)``

@Metadata {
    @SupportedLanguage(swift)
    @Available(macOS, introduced: "11.0")
    @DocumentationExtension(mergeBehavior: override)
}

@Options {
    @AutomaticSeeAlso(disabled)
    @AutomaticArticleSubheading(disabled)
}

One or more expected asset paths were not found in the R2 manifest.

## Overview

Thrown by ``HarnessKitCatalogue/prefetch(for:)`` when the loaded manifest does not contain entries for all requested bezel paths. The associated `paths` array lists the missing relative paths, sorted alphabetically. The ``errorDescription`` output displays up to 10 paths; if more are missing, a count of the remaining entries is appended.

This typically indicates that the manifest was generated without including these files. Regenerate and redeploy the manifest on the R2 bucket, then call ``HarnessKitCatalogue/refresh()`` to pick up the changes.

## See Also

- ``manifestNotLoaded``

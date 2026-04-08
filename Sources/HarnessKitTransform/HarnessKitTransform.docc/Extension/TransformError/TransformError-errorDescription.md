# ``HarnessKitTransform/TransformError/errorDescription``

@Metadata {
    @SupportedLanguage(swift)
    @Available(macOS, introduced: "11.0")
    @DocumentationExtension(mergeBehavior: override)
}

@Options {
    @AutomaticSeeAlso(disabled)
    @AutomaticArticleSubheading(disabled)
}

A human-readable description of the error, suitable for logging and diagnostics.

## Overview

Returns a `String?` that describes what went wrong, including any associated context such as screenshot IDs, device IDs, file paths, or underlying error messages. This property is the `LocalizedError` requirement and is what `error.localizedDescription` surfaces.

For ``notInManifest(paths:)``, the description lists up to 10 missing paths and appends a count of any remaining entries beyond that limit.

# ``HarnessKitScreenshots/VersionedBezel/id``

@Metadata {
    @SupportedLanguage(swift)
    @Available(iOS, introduced: "14.0")
    @Available(iPadOS, introduced: "14.0")
    @Available(macOS, introduced: "11.0")
    @Available(tvOS, introduced: "14.0")
    @Available(watchOS, introduced: "10.0")
    @Available(visionOS, introduced: "1.0")
    @DocumentationExtension(mergeBehavior: override)
}
@Options {
    @AutomaticSeeAlso(disabled)
    @AutomaticArticleSubheading(disabled)
}

An auto-generated unique identifier for `Identifiable` conformance.

## Overview

`id` is assigned a new `UUID` value by default when a ``VersionedBezel`` is created. It satisfies the `Identifiable` requirement so that bezel entries can be used directly in SwiftUI `ForEach` and `List` views.

When decoding from JSON, the `id` field is optional -- if the JSON omits it, a fresh UUID is generated automatically. This means hand-authored config files do not need to include an `id` key.

## See Also
- ``HarnessKitScreenshots/VersionedBezel``

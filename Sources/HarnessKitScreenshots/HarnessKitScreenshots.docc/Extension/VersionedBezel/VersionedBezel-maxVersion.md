# ``HarnessKitScreenshots/VersionedBezel/maxVersion``

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

The maximum OS version (exclusive) this bezel applies to.

## Overview

`maxVersion` is an optional version string that defines the exclusive upper bound of the version range. When set to a value like `"26.0"`, the bezel matches screenshots with an `osVersion` that is strictly less than this value. When `nil`, the entry has no upper bound and matches all versions from ``minVersion`` onward.

Use `maxVersion` to partition version ranges across multiple bezel entries -- for example, one entry covering iOS 16.0 to 26.0 and another covering 26.0 and above.

## See Also
- ``HarnessKitScreenshots/VersionedBezel``

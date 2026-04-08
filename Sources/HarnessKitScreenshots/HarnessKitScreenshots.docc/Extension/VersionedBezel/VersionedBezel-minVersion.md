# ``HarnessKitScreenshots/VersionedBezel/minVersion``

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

The minimum OS version (inclusive) this bezel applies to.

## Overview

`minVersion` is a version string such as `"16.0"` or `"26.0"` that defines the inclusive lower bound of the version range for this bezel entry. When ``ScreenshotConfig/matchedBezel(for:)`` evaluates candidates, it checks that the screenshot's `osVersion` is greater than or equal to this value using numeric string comparison.

Pair `minVersion` with ``maxVersion`` to create bounded ranges, or leave ``maxVersion`` as `nil` to match all versions from this point forward.

## See Also
- ``HarnessKitScreenshots/VersionedBezel``

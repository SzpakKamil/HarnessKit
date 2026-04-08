# ``HarnessKitScreenshots/TargetOS/id-property``

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

The stable identity value for use in `Identifiable` conformance.

## Overview

Returns the `rawValue` of the enum case, such as `"iOS"`, `"macOS"`, or `"visionOS"`. This makes `TargetOS` suitable for use in SwiftUI `ForEach` and other contexts that require `Identifiable` conformance.

## See Also

- ``HarnessKitScreenshots/TargetOS/currentOS``

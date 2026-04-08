# ``HarnessKitScreenshots/TargetOS/macOS``

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

The macOS target operating system, representing Mac.

## Overview

Use the `macOS` case when configuring screenshots or bezels for Mac devices. The raw value is `"macOS"`. You can check for this case using the convenience property ``HarnessKitScreenshots/TargetOS/isMacOS``.

## See Also

- ``HarnessKitScreenshots/TargetOS/isMacOS``
- ``HarnessKitScreenshots/TargetOS/currentOS``

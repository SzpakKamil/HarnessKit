# ``HarnessKitScreenshots/TargetOS/iPadOS``

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

The iPadOS target operating system, representing iPad.

## Overview

Use the `iPadOS` case when configuring screenshots or bezels for iPad devices. The raw value is `"iPadOS"`. On a physical device, ``HarnessKitScreenshots/TargetOS/currentOS`` returns this case when the user interface idiom is `.pad`.

## See Also

- ``HarnessKitScreenshots/TargetOS/iOS``
- ``HarnessKitScreenshots/TargetOS/currentOS``

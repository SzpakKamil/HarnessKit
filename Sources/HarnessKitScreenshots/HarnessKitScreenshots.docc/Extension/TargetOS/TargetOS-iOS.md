# ``HarnessKitScreenshots/TargetOS/iOS``

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

The iOS target operating system, representing iPhone.

## Overview

Use the `iOS` case when configuring screenshots or bezels for iPhone devices. The raw value is `"iOS"`. On a physical device, ``HarnessKitScreenshots/TargetOS/currentOS`` returns this case when the user interface idiom is `.phone`.

## See Also

- ``HarnessKitScreenshots/TargetOS/iPadOS``
- ``HarnessKitScreenshots/TargetOS/currentOS``

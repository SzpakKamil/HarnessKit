# ``HarnessKitScreenshots/TargetOS/tvOS``

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

The tvOS target operating system, representing Apple TV.

## Overview

Use the `tvOS` case when configuring screenshots or bezels for Apple TV. The raw value is `"tvOS"`. On a tvOS device, ``HarnessKitScreenshots/TargetOS/currentOS`` returns this case automatically.

## See Also

- ``HarnessKitScreenshots/TargetOS/currentOS``

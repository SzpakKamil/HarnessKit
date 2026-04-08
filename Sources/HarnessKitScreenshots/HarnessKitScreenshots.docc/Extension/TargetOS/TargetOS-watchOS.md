# ``HarnessKitScreenshots/TargetOS/watchOS``

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

The watchOS target operating system, representing Apple Watch.

## Overview

Use the `watchOS` case when configuring screenshots or bezels for Apple Watch. The raw value is `"watchOS"`. On a watchOS device, ``HarnessKitScreenshots/TargetOS/currentOS`` returns this case automatically.

## See Also

- ``HarnessKitScreenshots/TargetOS/currentOS``

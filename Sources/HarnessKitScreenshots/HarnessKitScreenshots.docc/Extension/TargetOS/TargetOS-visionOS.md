# ``HarnessKitScreenshots/TargetOS/visionOS``

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

The visionOS target operating system, representing Apple Vision Pro.

## Overview

Use the `visionOS` case when configuring screenshots or bezels for Apple Vision Pro. The raw value is `"visionOS"`. On a visionOS device, ``HarnessKitScreenshots/TargetOS/currentOS`` returns this case automatically.

## See Also

- ``HarnessKitScreenshots/TargetOS/currentOS``

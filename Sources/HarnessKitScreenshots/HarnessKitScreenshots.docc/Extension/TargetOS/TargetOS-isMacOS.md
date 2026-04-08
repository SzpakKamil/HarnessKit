# ``HarnessKitScreenshots/TargetOS/isMacOS``

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

A Boolean indicating whether this target is macOS.

## Overview

Returns `true` when the value is ``HarnessKitScreenshots/TargetOS/macOS`` and `false` for all other cases. Use this convenience property when you need to branch logic specifically for Mac targets, such as applying window-chrome bezels instead of device bezels.

## See Also

- ``HarnessKitScreenshots/TargetOS/macOS``
- ``HarnessKitScreenshots/TargetOS/currentOS``

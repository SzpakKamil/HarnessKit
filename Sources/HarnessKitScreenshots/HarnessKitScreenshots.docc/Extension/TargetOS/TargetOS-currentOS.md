# ``HarnessKitScreenshots/TargetOS/currentOS``

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

The operating system the app is currently running on.

## Overview

Returns the ``HarnessKitScreenshots/TargetOS`` case that corresponds to the current platform at runtime. On iOS, it distinguishes between iPhone (``HarnessKitScreenshots/TargetOS/iOS``) and iPad (``HarnessKitScreenshots/TargetOS/iPadOS``) using `UIDevice.current.userInterfaceIdiom`. On all other platforms, it returns the matching case directly.

## See Also

- ``HarnessKitScreenshots/TargetOS/isMacOS``

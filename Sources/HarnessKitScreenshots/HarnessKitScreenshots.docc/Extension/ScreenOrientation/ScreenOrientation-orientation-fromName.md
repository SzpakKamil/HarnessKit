# ``HarnessKitScreenshots/ScreenOrientation/orientation(from:)``

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

Returns the orientation matching a given lowercase name string.

## Overview

Pass `"portrait"` or `"landscape"` to receive the corresponding ``HarnessKitScreenshots/ScreenOrientation`` case. The method expects lowercase input and triggers a fatal error if the string does not match a known orientation. Use this when deserializing orientation values from external sources such as configuration files.

## See Also

- ``HarnessKitScreenshots/ScreenOrientation/orientation(fromSize:)``

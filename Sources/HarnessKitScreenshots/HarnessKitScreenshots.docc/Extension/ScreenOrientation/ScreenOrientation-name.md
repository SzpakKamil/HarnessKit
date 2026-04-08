# ``HarnessKitScreenshots/ScreenOrientation/name``

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

A human-readable name for the orientation.

## Overview

Returns the raw value of the enum case, which is either `"Portrait"` or `"Landscape"`. This property is also used as the basis for the ``HarnessKitScreenshots/ScreenOrientation/id-property`` conformance to `Identifiable`.

## See Also

- ``HarnessKitScreenshots/ScreenOrientation/id-property``

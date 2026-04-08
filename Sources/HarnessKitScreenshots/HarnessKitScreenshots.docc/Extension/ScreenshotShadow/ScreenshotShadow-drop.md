# ``HarnessKitScreenshots/ScreenshotShadow/drop(_:)``

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

A drop shadow that follows the device bezel's alpha shape.

## Overview

The associated ``DropShadow`` value controls the color, opacity, blur radius, and offset of the shadow. All spatial values are expressed as fractions of the device's short side, making them resolution-independent.

Drop shadows trace the bezel silhouette, so the shadow outline matches the device outline exactly. This is distinct from shape shadows, which are independent geometric forms.

## See Also
- ``HarnessKitScreenshots/ScreenshotShadow/shape(_:)``
- ``HarnessKitScreenshots/DropShadow``

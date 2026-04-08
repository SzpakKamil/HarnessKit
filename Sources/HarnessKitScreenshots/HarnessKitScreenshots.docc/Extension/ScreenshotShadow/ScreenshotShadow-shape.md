# ``HarnessKitScreenshots/ScreenshotShadow/shape(_:)``

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

An independent shape shadow placed relative to the device.

## Overview

The associated ``ShapeShadow`` value defines a standalone geometric shadow drawn independently of the device image. A common use is a contact shadow ellipse beneath the device, creating the illusion that it floats above the background.

Shape shadows have their own position, size, corner radius, and blur, all expressed as fractions of the device's short side for resolution-independent sizing.

## See Also
- ``HarnessKitScreenshots/ScreenshotShadow/drop(_:)``
- ``HarnessKitScreenshots/ShapeShadow``

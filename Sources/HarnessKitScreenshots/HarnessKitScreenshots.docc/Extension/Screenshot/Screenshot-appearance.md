# ``HarnessKitScreenshots/Screenshot/appearance``

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

The color scheme applied to the device during capture.

## Overview

Set `appearance` to ``ScreenshotAppearance/light`` or ``ScreenshotAppearance/dark`` to control the system theme forced onto the simulator before the screenshot is taken. During capture, `captureScreenshot` writes this value to `XCUIDevice.shared.appearance`. The appearance is also encoded in the serialized filename so the transform pipeline can select the correct bezel variant.

## See Also
- ``HarnessKitScreenshots/Screenshot``
- ``HarnessKitScreenshots/ScreenshotAppearance``

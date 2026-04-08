# ``HarnessKitScreenshots/Screenshot/backgroundHex``

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

A backward-compatible computed property that extracts the solid hex color from the background.

## Overview

`backgroundHex` returns the hex string when ``background`` is ``ScreenshotBackground/solid(hex:)``, and `nil` for all other background types including gradients, images, and `nil` backgrounds. This property exists for backward compatibility with older configuration files that stored the background as a plain hex string. Prefer reading ``background`` directly in new code.

## See Also
- ``HarnessKitScreenshots/Screenshot``
- ``HarnessKitScreenshots/Screenshot/background``
- ``HarnessKitScreenshots/ScreenshotBackground``

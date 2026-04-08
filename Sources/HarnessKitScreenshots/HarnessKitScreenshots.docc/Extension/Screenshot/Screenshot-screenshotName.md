# ``HarnessKitScreenshots/Screenshot/screenshotName()``

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

Serializes all screenshot metadata into a stable flat-string filename.

## Overview

`screenshotName()` encodes every property of the screenshot into a single caret-separated string ending in `.png`. The format uses `key*value` pairs joined by `^`, for example `id*home^os*iOS^appearance*Light^crop*0.0,0.0,1.0,1.0^background*solid:F2F2F7.png`. This string is used as the XCTest attachment name so that the transform tool can reconstruct the full `Screenshot` value without needing a side-channel configuration file. Parse it back with ``fromScreenshotName(_:)``.

## See Also
- ``HarnessKitScreenshots/Screenshot``
- ``HarnessKitScreenshots/Screenshot/fromScreenshotName(_:)``
- ``HarnessKitScreenshots/Screenshot/prettyName()``

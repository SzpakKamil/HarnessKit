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

Serializes the screenshot into a stable filename string.

## Overview

`screenshotName()` flattens every property of the screenshot into a single caret-separated string ending in `.png`. The format uses `key*value` pairs joined by `^`, for example:

```
id*home^os*iOS^orientation*nil^appearance*Light^osVersion*26.0.png
```

Keys appear in a fixed order: `id`, `os`, `orientation`, `appearance`, then `osVersion` and `addBezel` when they carry non-default values. `captureScreenshot` uses the result as the XCTest attachment name so any tool that reads the PNGs back can reconstruct the original `Screenshot` without a sidecar file. Parse the string back with ``fromScreenshotName(_:)``.

## See Also
- ``HarnessKitScreenshots/Screenshot``
- ``HarnessKitScreenshots/Screenshot/fromScreenshotName(_:)``
- ``HarnessKitScreenshots/Screenshot/prettyName()``

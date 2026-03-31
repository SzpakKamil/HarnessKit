# ``HarnessKitTransform/processScreenshotMacOS(image:config:screenshot:)``

@Metadata {
    @SupportedLanguage(swift)
    @Available(macOS, introduced: "11.0")
    @DocumentationExtension(mergeBehavior: override)
}

@Options {
    @AutomaticArticleSubheading(disabled)
}

Runs the macOS-specific transform pipeline and returns the composed image.

## Overview

The macOS pipeline differs from iOS in two ways:

- `prepareScreenshot` adds a drop shadow around the window screenshot and scales it to the 3456 × 2168 base canvas.
- `placeBezel` draws the bezel first and the screenshot on top (`screenshotOnTop: true`), matching the layering of a real Mac display.

When `screenshot.addBezel` is `false`, scaling and bezel placement are both skipped and the prepared screenshot is used directly.

Bezel is resolved from `config.macBezel` using `MacBezel`. The `borderImage` call requires both `os` and `appearance` because Mac bezels ship as separate PNGs per macOS version and color scheme.

## Throws

`TransformError.bezelNotFound` or `TransformError.bezelImageMissing`.

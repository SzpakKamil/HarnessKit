# ``HarnessKitTransform/processScreenshotIPadOS(image:config:screenshot:)``

@Metadata {
    @SupportedLanguage(swift)
    @Available(macOS, introduced: "11.0")
    @DocumentationExtension(mergeBehavior: override)
}

@Options {
    @AutomaticArticleSubheading(disabled)
}

Runs the iPadOS-specific transform pipeline and returns the composed image.

## Overview

Identical to the iOS pipeline but uses `config.padBezel` and `PadBezel` for bezel resolution, and applies `config.padOrientation` as the default orientation when `screenshot.orientation` is `nil`.

Pipeline steps (in order): `prepareScreenshot` → `maskScreenshot` → `scaleToBezel` → `placeBezel` → `applyOrientation` → `addBackgroundColor` → `cropImage` → `adjustResolution`.

## Throws

`TransformError.bezelNotFound` or `TransformError.bezelImageMissing`.

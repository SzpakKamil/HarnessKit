# ``HarnessKitTransform/processScreenshotWatchOS(image:config:screenshot:)``

@Metadata {
    @SupportedLanguage(swift)
    @Available(macOS, introduced: "11.0")
    @DocumentationExtension(mergeBehavior: override)
}

@Options {
    @AutomaticArticleSubheading(disabled)
}

Runs the watchOS-specific transform pipeline and returns the composed image.

## Overview

Pipeline steps (in order): `prepareScreenshot` → `maskScreenshot` → `scaleToBezel` → `placeBezel` → `addBackgroundColor` → `cropImage` → `adjustResolution`.

Watch screenshots do not go through `applyOrientation` because watchOS only produces portrait output. Bezel is resolved from `config.watchBezel` using `WatchBezel`.

## Throws

`TransformError.bezelNotFound` or `TransformError.bezelImageMissing`.

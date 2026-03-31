# ``HarnessKitTransform/processScreenshotTVOS(image:config:screenshot:)``

@Metadata {
    @SupportedLanguage(swift)
    @Available(macOS, introduced: "11.0")
    @DocumentationExtension(mergeBehavior: override)
}

@Options {
    @AutomaticArticleSubheading(disabled)
}

Runs the tvOS-specific transform pipeline and returns the composed image.

## Overview

Pipeline steps (in order): `prepareScreenshot` → `scaleToBezel` → `placeBezel` → `addBackgroundColor` → `cropImage` → `adjustResolution`.

The tvOS pipeline skips masking because Apple TV screenshots are rectangular with no display cutouts. Bezel is resolved from `config.tvBezel` using `OtherBezel`.

## Throws

`TransformError.bezelNotFound` or `TransformError.bezelImageMissing`.

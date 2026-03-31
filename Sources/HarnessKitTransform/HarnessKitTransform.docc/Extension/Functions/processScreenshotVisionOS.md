# ``HarnessKitTransform/processScreenshotVisionOS(image:config:screenshot:)``

@Metadata {
    @SupportedLanguage(swift)
    @Available(macOS, introduced: "11.0")
    @DocumentationExtension(mergeBehavior: override)
}

@Options {
    @AutomaticArticleSubheading(disabled)
}

Runs the visionOS-specific transform pipeline and returns the composed image.

## Overview

visionOS has no physical device bezel, so this processor skips masking and bezel placement entirely. It uses a neutral scale factor of `1.0`.

Pipeline steps (in order): `prepareScreenshot` → `scaleToBezel(factor: 1.0)` → `addBackgroundColor` → `cropImage` → `adjustResolution`.

This function does not throw — it has no bezel resolution step that could fail.

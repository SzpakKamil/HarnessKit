# ``HarnessKitTransform/processScreenshotIOS(image:config:screenshot:)``

@Metadata {
    @SupportedLanguage(swift)
    @Available(macOS, introduced: "11.0")
    @DocumentationExtension(mergeBehavior: override)
}

@Options {
    @AutomaticArticleSubheading(disabled)
}

Runs the iOS-specific transform pipeline and returns the composed image.

## Overview

Pipeline steps (in order):

1. `prepareScreenshot` — rotates landscape screenshots to portrait.
2. `maskScreenshot` — clips to the device's screen shape (skipped when `screenshot.addBezel` is `false`).
3. `scaleToBezel` — shrinks the screenshot using `PhoneBezel.scale`.
4. `placeBezel` — composites the bezel on top (skipped when `screenshot.addBezel` is `false`).
5. `applyOrientation` — rotates to landscape if configured.
6. `addBackgroundColor` — fills the canvas.
7. `cropImage` — applies the normalized crop.
8. `adjustResolution` — scales to the final canvas.

The bezel is resolved from `config.phoneBezel` using `screenshot.osVersion` via `resolveBezel`.

## Throws

`TransformError.bezelNotFound` or `TransformError.bezelImageMissing` if the config does not contain a valid bezel for this screenshot.

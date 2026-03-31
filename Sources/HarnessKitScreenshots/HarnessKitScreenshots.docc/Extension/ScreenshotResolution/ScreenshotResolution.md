# ``HarnessKitScreenshots/ScreenshotResolution``

@Metadata {
    @SupportedLanguage(swift)
    @DocumentationExtension(mergeBehavior: override)
}

@Options {
    @AutomaticSeeAlso(disabled)
}

The output canvas size for the final transformed image.

## Overview

`ScreenshotResolution` controls the last resize step in the transform pipeline. `adjustResolution(image:resolution:)` scales the composed image to fit inside the canvas while preserving aspect ratio and centering it on a transparent background.

| Case | Canvas |
| :--- | :--- |
| `.default` | 603 × 416 pt — standard App Store display |
| `.full` | 2089 × 1440 pt — maximum supported size |

Set the resolution in `ScreenshotConfig`:

```swift
var config = ScreenshotConfig.defaults
config.resolution = .full
```

## Topics

### Cases

- ``default``
- ``full``

### Properties

- ``size``

### Helpers

- ``option(for:)``

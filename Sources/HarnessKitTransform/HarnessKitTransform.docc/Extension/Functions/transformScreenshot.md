# ``HarnessKitTransform/transformScreenshot(image:screenshot:config:outputDirectory:)``

@Metadata {
    @SupportedLanguage(swift)
    @Available(macOS, introduced: "11.0")
    @DocumentationExtension(mergeBehavior: override)
}

@Options {
    @AutomaticArticleSubheading(disabled)
}

Runs the full platform-specific transform pipeline and saves the result as a PNG.

## Overview

`transformScreenshot` is the top-level convenience entry point. It calls `processScreenshot` to produce the composed `NSImage`, then writes it to `outputDirectory` using `saveResults`.

The output filename is `screenshot.prettyName() + ".png"` — for example, `"home-iOS.png"`.

## Parameters

| Name | Type | Description |
| :--- | :--- | :--- |
| `image` | `NSImage` | The raw screenshot captured during testing. |
| `screenshot` | `Screenshot` | Metadata driving the pipeline (OS, appearance, crop, etc.). |
| `config` | `ScreenshotConfig` | Versioned bezel and resolution config. |
| `outputDirectory` | `URL` | Directory where the PNG is written. Created if it does not exist. |

## Throws

`TransformError` if a required bezel is missing or if writing the PNG fails.

## Example

```swift
let config = await ScreenshotConfig.load()
let outputDir = URL(fileURLWithPath: "/Users/me/Desktop/Transformed")

try transformScreenshot(
    image: rawImage,
    screenshot: screenshot,
    config: config,
    outputDirectory: outputDir
)
```

## See Also

- ``processScreenshot(image:screenshot:config:)``
- ``saveResults(image:name:to:)``

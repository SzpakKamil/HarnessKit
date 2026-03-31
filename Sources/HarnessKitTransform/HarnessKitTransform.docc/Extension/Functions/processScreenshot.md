# ``HarnessKitTransform/processScreenshot(image:screenshot:config:)``

@Metadata {
    @SupportedLanguage(swift)
    @Available(macOS, introduced: "11.0")
    @DocumentationExtension(mergeBehavior: override)
}

@Options {
    @AutomaticArticleSubheading(disabled)
}

Runs the full platform-specific transform pipeline and returns the composed image.

## Overview

`processScreenshot` dispatches to the correct platform processor based on `screenshot.os` and returns the resulting `NSImage`. It does not save anything — call `saveResults(image:name:to:)` when you are ready to write to disk.

Use this function when you need to inspect or further modify the image before saving — for example, to preview it in a SwiftUI view or add a text overlay.

## Parameters

| Name | Type | Description |
| :--- | :--- | :--- |
| `image` | `NSImage` | The raw screenshot captured during testing. |
| `screenshot` | `Screenshot` | Metadata driving the pipeline. |
| `config` | `ScreenshotConfig` | Versioned bezel and resolution config. |

## Returns

The fully composed `NSImage` ready for display or export.

## Throws

`TransformError` if a required bezel is missing.

## Example

```swift
let result = try processScreenshot(image: rawImage, screenshot: screenshot, config: config)
// preview result in the UI, then save:
try saveResults(image: result, name: screenshot.prettyName(), to: outputDir)
```

## See Also

- ``transformScreenshot(image:screenshot:config:outputDirectory:)``

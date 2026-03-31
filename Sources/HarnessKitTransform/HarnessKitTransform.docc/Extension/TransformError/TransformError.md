# ``HarnessKitTransform/TransformError``

@Metadata {
    @SupportedLanguage(swift)
    @Available(macOS, introduced: "11.0")
    @DocumentationExtension(mergeBehavior: override)
}

@Options {
    @AutomaticSeeAlso(disabled)
}

Errors thrown by the screenshot transform pipeline.

## Overview

Every platform processor and `saveResults` throws `TransformError` rather than calling `fatalError`. This lets callers log the failure, skip the offending screenshot, and continue processing the rest.

```swift
do {
    try transformScreenshot(image: image, screenshot: screenshot, config: config, outputDirectory: dir)
} catch TransformError.bezelNotFound(let id) {
    print("No bezel configured for '\(id)' — skipping")
} catch TransformError.imageSaveFailed(let url, let error) {
    print("Could not write to \(url.path): \(error)")
} catch {
    print("Unexpected error: \(error.localizedDescription)")
}
```

## Topics

### Cases

- ``bezelNotFound(screenshotID:)``
- ``bezelImageMissing(bezelID:)``
- ``outputDirectoryUnavailable(_:_:)``
- ``imageSaveFailed(_:_:)``

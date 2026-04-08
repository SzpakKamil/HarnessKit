# ``HarnessKitTransform/TransformError/bezelNotFound(screenshotID:)``

@Metadata {
    @SupportedLanguage(swift)
    @Available(macOS, introduced: "11.0")
    @DocumentationExtension(mergeBehavior: override)
}

@Options {
    @AutomaticSeeAlso(disabled)
    @AutomaticArticleSubheading(disabled)
}

No bezel was found that matches the given screenshot's device and configuration.

## Overview

Thrown when the transform pipeline cannot locate a `VersionedBezel` entry for the `Screenshot` being processed. The associated `screenshotID` identifies which screenshot triggered the failure, making it straightforward to trace back to the `ScreenshotConfig` that is missing a bezel definition.

Verify that the `ScreenshotConfig` includes a bezel entry whose device ID matches the screenshot's target device.

## See Also

- ``bezelImageMissing(bezelID:)``
- ``bezelFileNotFound(id:color:)``

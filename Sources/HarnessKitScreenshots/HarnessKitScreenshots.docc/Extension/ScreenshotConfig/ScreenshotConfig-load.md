# ``HarnessKitScreenshots/ScreenshotConfig/load(from:)``

@Metadata {
    @SupportedLanguage(swift)
    @Available(iOS, introduced: "14.0")
    @Available(iPadOS, introduced: "14.0")
    @Available(macOS, introduced: "11.0")
    @Available(tvOS, introduced: "14.0")
    @Available(watchOS, introduced: "10.0")
    @Available(visionOS, introduced: "1.0")
    @DocumentationExtension(mergeBehavior: override)
}
@Options {
    @AutomaticSeeAlso(disabled)
    @AutomaticArticleSubheading(disabled)
}

Loads a screenshot configuration from a consumer-provided JSON file.

## Overview

`load(from:)` reads and decodes a `ScreenshotConfig` from the JSON file at the given URL. If the file does not exist or cannot be decoded, the method returns ``ScreenshotConfig/defaults`` instead of throwing an error. This makes it safe to call unconditionally during pipeline setup.

The JSON file should live in the consumer project -- for example in its Application Support directory or as a bundle resource -- not inside the HarnessKit package itself.

## See Also
- ``HarnessKitScreenshots/ScreenshotConfig``

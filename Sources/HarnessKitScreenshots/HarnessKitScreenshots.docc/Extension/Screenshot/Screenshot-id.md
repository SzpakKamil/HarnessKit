# ``HarnessKitScreenshots/Screenshot/id``

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

The unique identifier for this screenshot.

## Overview

The `id` property distinguishes each screenshot within a project's configuration. It is embedded in the serialized filename produced by ``screenshotName()`` and used by the transform pipeline to match captured attachments back to their metadata. Choose a short, descriptive, and stable string such as `"home"` or `"settings-dark"` because renaming it later invalidates any previously captured files.

## See Also
- ``HarnessKitScreenshots/Screenshot``
- ``HarnessKitScreenshots/Screenshot/screenshotName()``
- ``HarnessKitScreenshots/Screenshot/prettyName()``

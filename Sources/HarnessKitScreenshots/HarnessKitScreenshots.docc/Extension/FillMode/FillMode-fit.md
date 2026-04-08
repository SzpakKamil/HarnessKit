# ``HarnessKitScreenshots/FillMode/fit``

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

Scales content to fit entirely within the target frame.

## Overview

The `fit` mode scales the content proportionally so that the entire image is visible within the destination bounds. This may leave empty space (letterboxing or pillarboxing) on two sides if the aspect ratios do not match. Use this mode when preserving full visibility of the screenshot content is more important than filling every pixel of the frame.

## See Also

- ``HarnessKitScreenshots/FillMode/fill``

# ``HarnessKitScreenshots/FillMode/fill``

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

Scales content to completely fill the target frame.

## Overview

The `fill` mode scales the content proportionally so that it covers the entire destination bounds. Portions of the image that extend beyond the frame edges are clipped. Use this mode when a seamless, edge-to-edge presentation is more important than showing every part of the screenshot content.

## See Also

- ``HarnessKitScreenshots/FillMode/fit``

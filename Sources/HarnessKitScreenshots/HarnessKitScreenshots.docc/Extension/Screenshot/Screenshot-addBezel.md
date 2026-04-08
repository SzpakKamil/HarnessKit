# ``HarnessKitScreenshots/Screenshot/addBezel``

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

Whether to composite the device bezel frame around the screenshot.

## Overview

When `addBezel` is `true` (the default), the transform pipeline overlays the appropriate device bezel image onto the captured screenshot, producing a framed device mockup. Set it to `false` to output the raw screenshot without any device frame, which is useful for edge-to-edge marketing images or when the bezel would obscure important content. The value is only serialized into the filename when it is `false`, keeping the common case compact.

## See Also
- ``HarnessKitScreenshots/Screenshot``
- ``HarnessKitScreenshots/Screenshot/shadows``

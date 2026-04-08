# ``HarnessKitScreenshots/DropShadow/color``

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

The shadow color as a six-character hex string.

## Overview

Specify the color without a leading hash, for example `"000000"` for black. The color is combined with ``opacity`` at render time, so you can use a fully saturated hex value and control intensity separately.

The default value is `"000000"`.

## See Also
- ``HarnessKitScreenshots/DropShadow/opacity``

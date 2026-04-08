# ``HarnessKitScreenshots/ScreenshotConfig/visionBezel``

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

The versioned bezel array for the visionOS platform.

## Overview

`visionBezel` holds ``VersionedBezel`` entries for Apple Vision Pro. This array defaults to empty because ``ScreenshotConfig/matchedBezel(for:)`` currently returns `nil` for visionOS screenshots -- no device frame is composited.

Populate this array in anticipation of future bezel support. When the pipeline adds visionOS frame compositing, it will read entries from this array the same way it does for other platforms.

## See Also
- ``HarnessKitScreenshots/ScreenshotConfig``

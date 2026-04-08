# ``HarnessKitScreenshots/Screenshot/withOSVersion(_:)``

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

Returns a copy of this screenshot with the OS version set.

## Overview

`withOSVersion(_:)` produces a new `Screenshot` value identical to the receiver except that ``osVersion`` is set to the provided string. This method is called by `captureScreenshot` to stamp the real running OS major version (for example `"18.2"`) onto the screenshot metadata before it is serialized into the attachment name. You do not typically need to call this method directly; the capture infrastructure handles it automatically.

## See Also
- ``HarnessKitScreenshots/Screenshot``
- ``HarnessKitScreenshots/Screenshot/osVersion``

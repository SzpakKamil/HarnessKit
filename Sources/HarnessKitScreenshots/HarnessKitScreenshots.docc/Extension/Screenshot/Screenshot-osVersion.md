# ``HarnessKitScreenshots/Screenshot/osVersion``

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

The OS version string set automatically by the capture infrastructure.

## Overview

`osVersion` holds a version string such as `"17.0"` or `"18.2"` that records the real OS version running on the simulator at capture time. It is not exposed in the public initializers and is always `nil` when you create a `Screenshot` yourself. The capture infrastructure calls ``withOSVersion(_:)`` to stamp the correct value before attaching the screenshot. The transform pipeline later uses it to select the matching bezel variant for that OS release.

## See Also
- ``HarnessKitScreenshots/Screenshot``
- ``HarnessKitScreenshots/Screenshot/withOSVersion(_:)``
- ``HarnessKitScreenshots/Screenshot/os``

# ``HarnessKitScreenshots/Screenshot/os``

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

The target operating system platform for this screenshot.

## Overview

The `os` property tells the transform pipeline which device family and bezel set to use when compositing the final image. It defaults to `.currentOS`, which resolves to the platform the test is running on. Override it when your configuration file targets a platform different from the build destination, for example when generating assets for multiple platforms from a shared test suite.

## See Also
- ``HarnessKitScreenshots/Screenshot``
- ``HarnessKitScreenshots/TargetOS``
- ``HarnessKitScreenshots/Screenshot/osVersion``

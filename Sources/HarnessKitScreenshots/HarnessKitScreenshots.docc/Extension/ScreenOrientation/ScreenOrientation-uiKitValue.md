# ``HarnessKitScreenshots/ScreenOrientation/uiKitValue``

@Metadata {
    @SupportedLanguage(swift)
    @Available(iOS, introduced: "14.0")
    @Available(iPadOS, introduced: "14.0")
    @DocumentationExtension(mergeBehavior: override)
}
@Options {
    @AutomaticSeeAlso(disabled)
    @AutomaticArticleSubheading(disabled)
}

The corresponding `UIDeviceOrientation` value for this orientation.

## Overview

Available only on iOS, this property maps ``HarnessKitScreenshots/ScreenOrientation/portrait`` to `UIDeviceOrientation.portrait` and ``HarnessKitScreenshots/ScreenOrientation/landscape`` to `UIDeviceOrientation.landscapeLeft`. Use it when you need to bridge between `ScreenOrientation` and UIKit device orientation APIs.

## See Also

- ``HarnessKitScreenshots/ScreenOrientation/portrait``
- ``HarnessKitScreenshots/ScreenOrientation/landscape``

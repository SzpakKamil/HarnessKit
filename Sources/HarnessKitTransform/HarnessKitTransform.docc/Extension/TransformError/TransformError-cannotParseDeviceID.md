# ``HarnessKitTransform/TransformError/cannotParseDeviceID(id:)``

@Metadata {
    @SupportedLanguage(swift)
    @Available(macOS, introduced: "11.0")
    @DocumentationExtension(mergeBehavior: override)
}

@Options {
    @AutomaticSeeAlso(disabled)
    @AutomaticArticleSubheading(disabled)
}

The device ID string could not be parsed into its expected components.

## Overview

Thrown when a device ID does not match any recognized format. For example, iPad device IDs are expected to end with a processor suffix like `M4` or `A18Pro` (e.g. `iPadAir11M4`), and Mac device IDs must contain a size and processor pattern (e.g. `MacbookPro14M4`).

Check that the device ID in your `ScreenshotConfig` follows the naming conventions documented for each platform.

## See Also

- ``descriptorNotFound(id:catalogue:)``

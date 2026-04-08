# ``HarnessKitTransform/TransformError/descriptorNotFound(id:catalogue:)``

@Metadata {
    @SupportedLanguage(swift)
    @Available(macOS, introduced: "11.0")
    @DocumentationExtension(mergeBehavior: override)
}

@Options {
    @AutomaticSeeAlso(disabled)
    @AutomaticArticleSubheading(disabled)
}

A ``DeviceDescriptor`` was not found in the specified catalogue JSON.

## Overview

Thrown when the transform pipeline looks up a device by `id` in a catalogue JSON (e.g. `catalogue/mac.json`) and no matching entry exists. The `catalogue` parameter names the file that was searched.

This usually means the device was added to the remote catalogue after the last ``HarnessKitCatalogue/refresh()`` call, or the device ID in the `ScreenshotConfig` contains a typo.

## See Also

- ``cannotParseDeviceID(id:)``

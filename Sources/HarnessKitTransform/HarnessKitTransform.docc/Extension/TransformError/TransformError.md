# ``HarnessKitTransform/TransformError``

@Metadata {
    @SupportedLanguage(swift)
    @Available(macOS, introduced: "11.0")
    @DocumentationExtension(mergeBehavior: override)
}

@Options {
    @AutomaticSeeAlso(disabled)
    @AutomaticArticleSubheading(disabled)
}

Errors thrown by the HarnessKitTransform pipeline during bezel compositing, asset lookup, and file I/O.

## Overview

``TransformError`` conforms to `LocalizedError` and provides human-readable descriptions through its ``errorDescription`` property. Each case captures enough context -- screenshot IDs, bezel IDs, device IDs, file paths -- to diagnose failures without additional logging.

| Case | When It Occurs |
| :--- | :------------- |
| ``bezelNotFound(screenshotID:)`` | No bezel matches the screenshot's device and configuration. |
| ``bezelImageMissing(bezelID:)`` | The bezel entry exists but its PNG image could not be loaded. |
| ``bezelFileNotFound(id:color:)`` | A bezel PNG was not found in the object cache or the SPM bundle. |
| ``descriptorNotFound(id:catalogue:)`` | A device descriptor is missing from the specified catalogue JSON. |
| ``cannotParseDeviceID(id:)`` | The device ID string does not match any expected format. |
| ``notInManifest(paths:)`` | One or more expected paths were absent from the R2 manifest. |
| ``manifestNotLoaded`` | No manifest is available; ``HarnessKitCatalogue/refresh()`` has not been called or failed. |
| ``outputDirectoryUnavailable(_:_:)`` | The output directory could not be created. |
| ``imageSaveFailed(_:_:)`` | Writing the final composited image to disk failed. |

## Topics

### Bezel Lookup Errors

- ``bezelNotFound(screenshotID:)``
- ``bezelImageMissing(bezelID:)``
- ``bezelFileNotFound(id:color:)``

### Descriptor and Device Errors

- ``descriptorNotFound(id:catalogue:)``
- ``cannotParseDeviceID(id:)``

### Catalogue Errors

- ``notInManifest(paths:)``
- ``manifestNotLoaded``

### File I/O Errors

- ``outputDirectoryUnavailable(_:_:)``
- ``imageSaveFailed(_:_:)``

### Localized Description

- ``errorDescription``

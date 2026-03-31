# ``HarnessKitScreenshots/ExportPath``

@Metadata {
    @SupportedLanguage(swift)
    @Available(macOS, introduced: "11.0")
    @DocumentationExtension(mergeBehavior: override)
}

@Options {
    @AutomaticSeeAlso(disabled)
}

A named export destination persisted to disk by the Tester app.

## Overview

`ExportPath` maps a human-readable name to a file-system path where the Tester app copies transformed screenshots. The full list is saved as `export_paths.json` inside the app's Application Support directory and survives app restarts.

> Note: `ExportPath` is macOS-only. It relies on `FileManager.applicationSupportDirectory`, which is unavailable on other platforms.

```swift
// Save a new destination
var paths = try ExportPath.load()
paths.append(ExportPath(id: "App Store", destination: "/Users/me/Desktop/AppStore"))
try ExportPath.save(paths)

// Load on next launch
let destinations = try ExportPath.load()
```

## Topics

### Properties

- ``id``
- ``destination``
- ``name``

### Persistence

- ``save(_:)``
- ``load()``

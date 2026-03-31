# ``HarnessKitScreenshots/VersionedBezel``

@Metadata {
    @SupportedLanguage(swift)
    @DocumentationExtension(mergeBehavior: override)
}

@Options {
    @AutomaticSeeAlso(disabled)
}

A bezel ID paired with the OS version range it applies to.

## Overview

`VersionedBezel` entries live inside `ScreenshotConfig` as arrays — one per platform. During transformation, `resolveBezel(from:for:bezelType:)` finds the first entry whose `[minVersion, maxVersion)` range covers `Screenshot.osVersion` and resolves its `bezelID` to a concrete `BezelDescriptor` case.

This solves the problem of testers running different OS versions: an iOS 17 simulator must use an iPhone 16 bezel, while iOS 26 testers should get an iPhone 17 bezel.

```swift
let phoneBezel: [VersionedBezel] = [
    // iOS 16.0 up to (not including) 26.0 → iPhone 16 Black
    VersionedBezel(minVersion: "16.0", maxVersion: "26.0", bezelID: "iPhone16Black"),
    // iOS 26.0 and above → iPhone 17 Black
    VersionedBezel(minVersion: "26.0", bezelID: "iPhone17Black")
]
```

If no entry matches — or if `Screenshot.osVersion` is `nil` — the pipeline falls back to the last entry in the array.

## Topics

### Properties

- ``minVersion``
- ``maxVersion``
- ``bezelID``

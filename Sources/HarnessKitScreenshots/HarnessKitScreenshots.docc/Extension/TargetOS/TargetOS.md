# ``HarnessKitScreenshots/TargetOS``

@Metadata {
    @SupportedLanguage(swift)
    @DocumentationExtension(mergeBehavior: override)
}

@Options {
    @AutomaticSeeAlso(disabled)
}

The Apple platform a screenshot targets.

## Overview

Set `os` on a `Screenshot` to tell the transform pipeline which bezel pool and compositing logic to use. The pipeline branches on this value: iOS and iPadOS screenshots go through mask → scale → place bezel, macOS adds a drop shadow during preparation, and visionOS skips the bezel step entirely.

Use `TargetOS.currentOS` as the default when you run tests on a single platform and don't need to specify it manually:

```swift
let screenshot = Screenshot(id: "home", appearance: .light)
// os defaults to .currentOS — .iOS on iPhone, .iPadOS on iPad, etc.
```

Provide an explicit value when the same test suite captures screenshots for multiple platforms or when the type is constructed outside of a test context:

```swift
let screenshot = Screenshot(id: "home", appearance: .light, os: .iOS, osVersion: "18.2")
```

## Topics

### Cases

- ``iOS``
- ``iPadOS``
- ``watchOS``
- ``tvOS``
- ``visionOS``
- ``macOSTahoe``
- ``macOSSequoia``

### Properties

- ``isMacOS``

### Static Helpers

- ``currentOS``
- ``newestMacOS``

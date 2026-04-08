# ``HarnessKit/PathComponent/pathIds``

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

The sequence of integer indices from the project root to this component.

## Overview

`pathIds` is built recursively as the hierarchy is resolved. A ``PathProject`` returns `[]` (the root has no parent index). Each ``PathFolder`` appends its position within its parent's ``folders`` array. For `Int`-raw-value enum cases, the case's `rawValue` is appended as the final element.

This path is used internally by `HarnessKitTesting` on tvOS, where navigation is driven by `XCUIRemote` directional presses calculated from these indices.

```swift
// Given: MyProject → ButtonsFolder (index 0) → .secondary (rawValue 1)
ButtonsFolder.secondary.pathIds  // [0, 1]
```

## See Also

- ``nameComponents``
- ``HarnessKit/PathFolder/ids(for:)``

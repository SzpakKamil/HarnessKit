# ``HarnessKit/PathComponent/nameComponents``

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

The display-name components from the project root to this component.

## Overview

`nameComponents` is built recursively alongside ``pathIds``. A ``PathProject`` returns `[]`. Each ``PathFolder`` appends its ``PathFolder/name``. For enum cases, the case name (derived via `Mirror`) is appended as the final element.

This path is used internally by `HarnessKitTesting` on iOS and macOS, where navigation is driven by tapping or clicking buttons matched by label text.

```swift
// Given: MyProject → ButtonsFolder → .primary
ButtonsFolder.primary.nameComponents  // ["Buttons", "primary"]
```

Joined with `/`, this produces a slash-separated path string useful for accessibility identifiers or debugging:

```swift
ButtonsFolder.primary.namePath  // "Buttons/primary"
```

## See Also

- ``pathIds``
- ``HarnessKit/PathFolder/names(for:)``
- ``HarnessKit/PathFolder/namePath(for:)``

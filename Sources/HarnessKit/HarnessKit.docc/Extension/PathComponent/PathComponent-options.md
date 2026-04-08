# ``HarnessKit/PathComponent/options``

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

The navigable case instances rendered as rows in the navigation list.

## Overview

`options` provides the leaf-level items that ``HarnessView`` displays below any sub-folders. Each element is an instance of a type conforming to ``PathFolder`` — typically an enum case. Selecting an option in the navigation list presents the view returned by ``PathFolder/view``.

The default implementation returns an empty array. Override it in your ``PathFolder`` enum to expose cases:

```swift
enum ButtonsFolder: Int, PathFolder {
    typealias ParentSection = MyProject
    static let name = "Buttons"

    case primary
    case secondary

    static var options: [any PathFolder] {
        [ButtonsFolder.primary, ButtonsFolder.secondary]
    }
}
```

## See Also

- ``folders``
- ``HarnessKit/PathFolder/view``

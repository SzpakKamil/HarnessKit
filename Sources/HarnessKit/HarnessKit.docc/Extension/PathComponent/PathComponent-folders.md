# ``HarnessKit/PathComponent/folders``

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

The ordered list of sub-folder types nested inside this component.

## Overview

`folders` defines the navigation hierarchy. Each element is a metatype conforming to ``PathFolder``. ``HarnessView`` renders one navigation row per folder, and `PathFolder/navigate(app:)` uses the folder order to calculate tap indices.

For ``PathProject``, this is the top-level list of sections. For ``PathFolder``, these are nested sub-folders that appear above the folder's own `options` in the navigation list.

The default implementation returns an empty array.

```swift
enum MyProject: PathProject {
    static let name = "Design System"
    static let folders: [any PathFolder.Type] = [
        ButtonsFolder.self,
        LabelsFolder.self
    ]
}
```

## See Also

- ``options``
- ``HarnessKit/PathFolder``
- ``HarnessKit/PathProject``

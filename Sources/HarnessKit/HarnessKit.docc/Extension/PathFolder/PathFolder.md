# ``HarnessKit/PathFolder``

A section or leaf level in a HarnessKit navigation hierarchy.

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

## Overview

Conform an `enum` to `PathFolder` to define a group of navigable views within a ``PathProject``. Each enum case represents one navigable option (a leaf view), while the folder itself acts as a section title in the navigation list. Folders can also be nested by populating the ``folders`` property with sub-folder types.

`PathFolder` requires `CaseIterable` so the framework can enumerate all options automatically. Conforming types are typically `Int`-raw-value enums to support tvOS remote navigation, where the framework calculates the number of remote-down presses required based on the case's raw value.

> Note: All members must be accessed on the main actor. Conforms to `Sendable`.

### Implementation Details

- **Type Erasure**: The ``view-27d1d`` property returns an associated type ``Content``. `HarnessKit` performs internal type-erasure, allowing you to return `some View` without ever needing to wrap it in `AnyView` manually.
- **Path Resolution**: Path information is built recursively. A folder directly under a ``PathProject`` starts the path, and nested folders append their index and name. This enables the framework to resolve the full path from the project root to any leaf case.
- **TVOS Navigation**: On tvOS, navigation is driven by indices. Sub-folder rows appear first (one per element in ``folders``), followed by option rows in their `rawValue` order.

### Hierarchy Example

To use `PathFolder`, you must define a ``PathProject`` root and connect your folder to it using ``ParentSection``.

```swift
import SwiftUI
import HarnessKit

// 1. Define the Project Root
enum MyProject: PathProject {
    static let name = "My Component Library"
    static let folders: [any PathFolder.Type] = [
        ButtonsFolder.self
    ]
}

// 2. Define a Folder (Section)
enum ButtonsFolder: Int, PathFolder {
    typealias ParentSection = MyProject
    static let name = "Buttons"
    
    case primary
    case secondary
    case destructive

    var description: String {
        "\(self)".capitalized + " Button"
    }

    @ViewBuilder
    var view: some View {
        switch self {
        case .primary:     Text("Primary View")
        case .secondary:   Text("Secondary View")
        case .destructive: Text("Destructive View")
        }
    }
}

// 3. Render the Harness
struct App: View {
    var body: some View {
        HarnessView<MyProject>()
    }
}
```

## Requirements

| Name | Type | Description |
| :--- | :--- | :--- |
| ``ParentSection`` | `AssociatedType` | The type that contains this folder — either a ``PathProject`` or another ``PathFolder``. |
| ``name`` | `String` | The display name used as the navigation title for this folder's list. |
| ``Content`` | `View` | The SwiftUI view type returned by the ``view-27d1d`` property. |
| ``description-76x0w`` | `String` | The label displayed in the navigation list row for this option. |
| ``view-27d1d`` | ``Content`` | The SwiftUI view presented when the user navigates to this option. |

## Hierarchy and Options

| Name | Type | Description |
| :--- | :--- | :--- |
| ``folders`` | `[any PathFolder.Type]` | The ordered list of sub-folder types nested inside this folder. |
| ``options`` | `[any PathFolder]` | All navigable case instances of this folder, in declaration order. Defaults to `Array(allCases)`. |

## Path Information

These properties are automatically provided via extensions and are used by the framework for navigation and testing.

| Name | Type | Description |
| :--- | :--- | :--- |
| ``pathIds`` | `[Int]` | The ordered integer path from the project root to this level (folder or case). |
| ``nameComponents`` | `[String]` | The ordered display-name components from the project root to this level. |
| ``namePath`` | `String` | A slash-joined string representation of the full name path (e.g., "Buttons/Primary"). |

## Topics

### Requirements
- ``ParentSection``
- ``name``
- ``description-76x0w``
- ``view-27d1d``
- ``Content``

### Hierarchy and Options
- ``folders``
- ``options``

### Path Information (Static)
- ``pathIds``
- ``nameComponents``
- ``namePath``

### Path Information (Instance)
- ``pathIds-2v8w7``
- ``nameComponents-6l0zs``
- ``namePath-508su``

### Path Resolution
- ``ids(for:)``
- ``names(for:)``
- ``namePath(for:)``
- ``ids(forType:)``
- ``names(forType:)``
- ``namePath(forType:)``

### Navigation
- ``navigate(app:)-65qsk``
- ``navigate(app:)-4p96p``

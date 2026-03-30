# ``HarnessKit/PathFolder/namePath``

@Metadata {
    @PageColor(purple)
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

A slash-joined string representation of the full display name path from the project root to this folder type.

## Overview

The `namePath` property provides a human-readable identifier for a specific folder level within a ``PathProject`` hierarchy. It is constructed by joining all elements in ``PathFolder/nameComponents-7scze`` (static) with a forward slash (`/`) separator.

This property is particularly useful for:
- **Debugging**: Quickly identifying a folder's position in a deep hierarchy.
- **Accessibility**: Serving as a base for stable `accessibilityIdentifier` values in UI tests.
- **Internal Routing**: Assisting ``PathResolver`` in mapping string-based paths back to concrete types.

### Hierarchy Resolution

The value is computed recursively based on the `ParentSection` associated type:
1. If the parent is a ``PathProject``, the path is simply the folder's own `name`.
2. If the parent is another ``PathFolder``, the path is `ParentSection.namePath + "/" + name`.

### Usage Example

To ensure reproducibility, define a full hierarchy from the project root down to the folder level.

```swift
import HarnessKit
import SwiftUI

// 1. Define the Project Root
enum MyDesignSystem: PathProject {
    static let name = "Design System"
    static let folders: [any PathFolder.Type] = [ComponentsFolder.self]
}

// 2. Define a Top-Level Folder
enum ComponentsFolder: PathFolder {
    typealias ParentSection = MyDesignSystem
    static let name = "Components"
    static let folders: [any PathFolder.Type] = [ButtonsFolder.self]
    
    var view: some View { Text("Components Overview") }
}

// 3. Define a Nested Folder
enum ButtonsFolder: Int, PathFolder {
    typealias ParentSection = ComponentsFolder
    static let name = "Buttons"
    
    case primary, secondary
    var view: some View { Text("Buttons") }
}

// Verification:
// ComponentsFolder.namePath == "Components"
// ButtonsFolder.namePath    == "Components/Buttons"
```

## Property Details

| Property | Type | Description |
| :--- | :--- | :--- |
| `namePath` | `String` | The complete breadcrumb path of folder names, e.g., "Settings/Privacy/Permissions". |

## Topics

### Path Components
- ``PathFolder/name``
- ``PathFolder/nameComponents-7scze``
- ``PathFolder/pathIds-96oav``

### Related Symbols
- ``PathProject/namePath``
- ``PathResolver/namePath(forType:)``

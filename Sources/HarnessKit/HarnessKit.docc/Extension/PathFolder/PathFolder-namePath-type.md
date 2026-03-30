# ``HarnessKit/PathFolder/namePath(forType:)``

@Metadata {
    @SupportedLanguage(swift)
    @Available(iOS, introduced: "14.0")
    @Available(iPadOS, introduced: "14.0")
    @Available(macOS, introduced: "11.0")
    @Available(tvOS, introduced: "14.0")
    @Available(watchOS, introduced: "10.0")
    @Available(visionOS, introduced: "1.0")
    @Available(swift, introduced: "5.9")
    @Available(Xcode, introduced: "15.0")
    @DocumentationExtension(mergeBehavior: override)
}

@Options {
    @AutomaticSeeAlso(disabled)
    @AutomaticArticleSubheading(disabled)
}

Returns a slash-separated string representing the hierarchical name path to a specific folder type.

## Overview

The `namePath(forType:)` method provides a single slash-separated string representing the full path from the root ``HarnessKit/PathProject`` down to a specific ``HarnessKit/PathFolder`` type. 

### How it Works

The method recursively assembles the display names of all parent sections (projects and folders) and joins them with a forward slash (`/`). This path reflects the exact structure defined in your harness hierarchy, making it ideal for:

1.  **Debugging**: Quickly identifying a folder's position within a complex navigation tree.
2.  **Accessibility**: Generating stable identifiers for navigation elements.
3.  **Logging**: Providing human-readable breadcrumbs for navigation events.

### Reproducible Example

To generate a valid `namePath`, you must define a complete hierarchy from the root project down to the individual enum cases.

```swift
import SwiftUI
import HarnessKit

// 1. Define the Project (The root of the hierarchy)
enum DesignSystem: PathProject {
    static let name = "Design System"
    static let folders: [any PathFolder.Type] = [ComponentsFolder.self]
}

// 2. Define a Section Folder (A container for other folders)
enum ComponentsFolder: PathFolder {
    typealias ParentSection = DesignSystem
    static let name = "Components"
    static let folders: [any PathFolder.Type] = [ButtonsFolder.self]
}

// 3. Define a Leaf Folder (Contains the actual navigable cases)
enum ButtonsFolder: Int, PathFolder {
    typealias ParentSection = ComponentsFolder
    static let name = "Buttons"
    
    case primary
    case secondary
    
    var description: String {
        switch self {
        case .primary: "Primary Button"
        case .secondary: "Secondary Button"
        }
    }
    
    var view: some View {
        Text("Button Preview Content")
    }
}

// 4. Resolve the name path for the folder type
let path = ButtonsFolder.namePath(forType: ButtonsFolder.self)
// Result: "Components/Buttons"
```

## Parameters

| Name | Type | Description |
| :--- | :--- | :--- |
| `type` | `N.Type` | The metatype of the target ``HarnessKit/PathFolder`` to resolve. |

## Return Value

- **Type**: `String`
- **Structure**: A slash-joined path (e.g., `"Components/Buttons"`).

## Topics

### Resolving Type Paths

- ``HarnessKit/PathFolder/names(forType:)``
- ``HarnessKit/PathFolder/ids(forType:)``

### Resolving Instance Paths

- ``HarnessKit/PathFolder/namePath(for:)``

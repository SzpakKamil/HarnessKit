# ``HarnessKit/PathFolder/names(forType:)``

@Metadata {
    @SupportedLanguage(swift)
    @Available(iOS, introduced: "14.0")
    @Available(macOS, introduced: "11.0")
    @Available(tvOS, introduced: "14.0")
    @Available(watchOS, introduced: "10.0")
    @Available(visionOS, introduced: "1.0")
    @DocumentationExtension(mergeBehavior: override)
}

@Options {
    @AutomaticArticleSubheading(disabled)
}

Returns an ordered array of display-name components from the project root to a specific folder type.

## Overview

The `names(forType:)` method resolves the navigation path of a folder by recursively collecting the `name` property from the target folder and all its parent sections (projects or folders). 

This is particularly useful for programmatic navigation in UI tests or for generating breadcrumbs in custom UI components. Unlike the instance-based overload, this method targets the folder level itself rather than a specific navigable case.

### Usage

Use this when you need the path to navigate to a folder's list level.

```swift
import HarnessKit

// 1. Define the Project Root
enum MainProject: PathProject {
    static let name = "Design System"
    static let folders: [any PathFolder.Type] = [ComponentsFolder.self]
}

// 2. Define a Top-Level Folder
enum ComponentsFolder: PathFolder {
    typealias ParentSection = MainProject
    static let name = "Components"
    static let folders: [any PathFolder.Type] = [ButtonsFolder.self]
    
    case overview
    
    var description: String { "Overview of all components" }
}

// 3. Define a Nested Folder
enum ButtonsFolder: PathFolder {
    typealias ParentSection = ComponentsFolder
    static let name = "Buttons"
    
    case primary, secondary
    
    var description: String { 
        self == .primary ? "Standard Button" : "Secondary Button" 
    }
}

// Resolve the name components for the nested folder type
let names = PathFolder.names(forType: ButtonsFolder.self)
// Returns: ["Components", "Buttons"]
```

## Parameters

| Name | Type | Description |
| :--- | :--- | :--- |
| `type` | `N.Type` | The metatype of the ``HarnessKit/PathFolder`` to resolve. |

## Return Value

Returns an array of `String` components (e.g., `["Shapes", "BasicShapes"]`). Each string matches the label shown in the navigation list at that level.

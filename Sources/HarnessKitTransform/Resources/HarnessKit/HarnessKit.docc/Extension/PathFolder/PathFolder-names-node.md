# ``HarnessKit/PathFolder/names(for:)``

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
    @AutomaticArticleSubheading(disabled)
}

Returns the complete display-name path for a specific folder case.

## Overview

This method provides the sequence of human-readable labels that appear in the navigation hierarchy leading to a specific folder instance. It is the primary data source for touch and pointer-based navigation on iOS, watchOS, and macOS.

The method recursively assembles the `name` properties of each parent level starting from the root ``HarnessKit/PathProject``. For the target node, it uses the Swift identifier of the enum case (the `caseName`) as the final component.

### Hierarchy Construction

The name components are derived by traversing the structural tree:
1.  **Project Root**: Traversal begins at the ``HarnessKit/PathProject`` (the project's name is not included in the array).
2.  **Intermediate Folders**: Each nested ``HarnessKit/PathFolder`` level appends its static `name` property.
3.  **Target Node**: The specific enum case identifier (e.g., "primary") is appended as the final element.

> [!IMPORTANT]
> All protocol requirements and extensions in HarnessKit run on the `@MainActor`. Ensure this method is called from the main thread.

### Example Usage

To reproduce a full hierarchy from project to case, define the levels as follows:

```swift
// 1. Root Project
enum AppProject: PathProject {
    static let name = "My App"
    static let folders: [any PathFolder.Type] = [MainFolder.self]
}

// 2. Intermediate Folder
enum MainFolder: PathFolder {
    typealias ParentSection = AppProject
    static let name = "Main"
    static let folders: [any PathFolder.Type] = [ButtonsFolder.self]
}

// 3. Leaf Folder (with RawRepresentable for case identifiers)
enum ButtonsFolder: Int, PathFolder {
    typealias ParentSection = MainFolder
    static let name = "Buttons"
    case primary, secondary, destructive

    var description: String { 
        "\(self)".capitalized + " Style" 
    }
}

// Retrieve name components for a specific case
let components = ButtonsFolder.names(for: .primary)
// Result: ["Main", "Buttons", "primary"]
```

## Parameters

| Name | Type | Description |
| :--- | :--- | :--- |
| `node` | `N` | A specific enum case conforming to ``HarnessKit/PathFolder`` and `RawRepresentable<Int>`. |

### Return Value

An ordered array of display names (`[String]`). The strings match the labels shown in the navigation list rows and are used as accessibility identifiers during UI testing to navigate through the hierarchy.

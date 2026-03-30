# ``HarnessKit/PathProject/pathIds``

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
    @AutomaticArticleSubheading(disabled)
}

The ordered sequence of integer indices that uniquely identifies the project root in a navigation harness.

## Overview

For any type conforming to ``PathProject``, this property always returns an empty array `[]`. It serves as the immutable base of the navigation path, representing the root level of the harness hierarchy.

In the HarnessKit architecture, navigation paths are built recursively:
1.  **Project Root**: Always `[]`.
2.  **Top-level Folder**: Appends its index within the project's `folders` array to the project's `pathIds` (e.g., `[0]`).
3.  **Nested Folder**: Appends its index within its parent folder's `folders` array (e.g., `[0, 1]`).
4.  **Enum Case**: Appends its `rawValue` to the folder's `pathIds` (e.g., `[0, 1, 5]`).

This property is used internally by `PathResolver` and `PathFolderNavigation` to calculate the precise navigation steps required for platform-specific interactions, such as remote d-pad presses on tvOS.

### Implementation Detail

The default implementation is provided via a protocol extension. Since the project root has no parent, it contributes no segments to the path.

```swift
import HarnessKit
import SwiftUI

// 1. Define the Project (The Root)
// PathProject.pathIds is [] by default.
enum ComponentsProject: PathProject {
    static let name = "Component Library"
    static let folders: [any PathFolder.Type] = [
        ButtonsFolder.self // Index 0
    ]
}

// 2. Define a Folder (The Section)
// ButtonsFolder.pathIds is [0] (Project.pathIds + [0])
enum ButtonsFolder: Int, PathFolder {
    typealias ParentSection = ComponentsProject
    static let name = "Buttons"
    
    case primary    // rawValue 0
    case secondary  // rawValue 1
    
    var description: String {
        switch self {
        case .primary: "Primary Action"
        case .secondary: "Secondary Action"
        }
    }
    
    @ViewBuilder
    var view: some View {
        switch self {
        case .primary: Text("Primary View")
        case .secondary: Text("Secondary View")
        }
    }
}

// 3. Access the Path IDs
// ComponentsProject.pathIds          // Returns []
// ButtonsFolder.pathIds               // Returns [0]
// ButtonsFolder.primary.pathIds       // Returns [0, 0]
// ButtonsFolder.secondary.pathIds     // Returns [0, 1]
```

## Details

| Attribute | Value | Description |
| :--- | :--- | :--- |
| **Type** | `[Int]` | An array of zero-based integer indices. |
| **Default** | `[]` | Provided by the `PathProject` protocol extension. |
| **Visibility** | `internal` | The default implementation is hidden from generated docs via `@_documentation(visibility: internal)`. |

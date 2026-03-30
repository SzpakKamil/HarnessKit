# ``HarnessKit/PathProject/namePath``

@Metadata {
    @SupportedLanguage(swift)
    @PageColor(purple)
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

A slash-separated string representation of the full name path from root to the current level.

## Overview

The `namePath` property provides a unique, human-readable string identifier for any node in the HarnessKit navigation tree. It is constructed by joining the ``HarnessKit/PathProject/nameComponents`` using a forward slash (`/`) as a separator.

For a type conforming to ``HarnessKit/PathProject``, this property always returns an empty string (`""`) because the project represents the root of the hierarchy and contributes no parent name components. As you descend into folders and specific cases, this path expands to reflect the full navigation sequence.

> Note: All members of ``HarnessKit/PathProject``, including `namePath`, must be accessed on the **Main Actor**.

### Property Behavior

| Context | Implementation | Description |
| :--- | :--- | :--- |
| **Project Root** | `""` | The root level always returns an empty string. |
| **PathFolder** | `Parent/Folder` | Static property representing the folder's level. |
| **Folder Case** | `Parent/Folder/case` | Instance property representing a specific navigable leaf. |

### Usage in Hierarchy

The following example demonstrates how the `namePath` property behaves at each level of a HarnessKit implementation.

```swift
import HarnessKit
import SwiftUI

// 1. Define the Project (Root)
enum MyProject: PathProject {
    static let name = "My App"
    static let folders: [any PathFolder.Type] = [MainFolder.self]
}

// 2. Define a Folder
enum MainFolder: Int, PathFolder {
    typealias ParentSection = MyProject
    static let name = "Main"
    
    // 3. Define Cases (Leaves)
    case detail
    
    var description: String { "Detail View" }
    var view: some View { Text("Detail") }
}

// Accessing namePath at different levels:
print(MyProject.namePath)        // Output: ""
print(MainFolder.namePath)       // Output: "Main"
print(MainFolder.detail.namePath) // Output: "Main/detail"
```

## Development Use Cases

*   **Debugging:** Quickly identify the hierarchy position of a rendered view in logs or via the environment inspector.
*   **Accessibility:** Set the `accessibilityIdentifier` of views to their `namePath` for stable, predictable UI testing across platforms.
*   **Deep Linking:** Use the path string as a token to resolve and navigate to specific parts of the app programmatically using the internal path resolver.

## See Also

- ``HarnessKit/PathProject/nameComponents``
- ``HarnessKit/PathProject/name``
- ``HarnessKit/PathFolder/namePath``

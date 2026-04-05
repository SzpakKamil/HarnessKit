# ``HarnessKit/PathFolder/ids(forType:)``

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

Returns the ordered sequence of integer indices that uniquely identifies a folder type within the project hierarchy.

## Overview

Use this method when you need the path to navigate to a folder level itself, rather than a specific navigable case within it. This is particularly useful for UI testing folder-level views or performing broad navigation steps in deep hierarchies.

The method recursively calculates the indices of each folder type within its parent's `folders` array, walking up to the root ``HarnessKit/PathProject``.

### Reproducible Example

This example demonstrates a complete hierarchy from the project root down to a specific folder.

```swift
import HarnessKit
import SwiftUI

// 1. Define the Project Root
enum MyProject: PathProject {
    static let name = "My Component Library"
    static let folders: [any PathFolder.Type] = [
        SettingsFolder.self,
        ButtonsFolder.self // Index 1
    ]
}

// 2. Define a Folder Section
enum ButtonsFolder: Int, PathFolder {
    typealias ParentSection = MyProject
    static let name = "Buttons"
    
    // 3. Define Cases (Leaf nodes)
    case primary = 0
    case secondary = 1
    
    var description: String { String(describing: self) }
    
    var view: some View { 
        Text(namePath) 
    }
}

// Resolve the path for the folder level
let folderPath = ButtonsFolder.ids(forType: ButtonsFolder.self)
// Result: [1] because ButtonsFolder is the second element in MyProject.folders
```

## Parameters

| Name | Type | Description |
| :--- | :--- | :--- |
| `type` | `N.Type` | The ``HarnessKit/PathFolder`` metatype (e.g., `ButtonsFolder.self`) for which the path is requested. |

## Return Value

- **Type**: `[Int]`
- **Description**: An ordered array of zero-based indices. The first element corresponds to the index in the ``HarnessKit/PathProject/folders`` array, and subsequent elements represent nested folder indices.

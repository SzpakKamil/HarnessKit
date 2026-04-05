# ``HarnessKit/PathFolder/pathIds``

@Metadata {
    @TitleHeading("Static Property")
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

The ordered integer path from the project root to this folder type.

## Overview

The `pathIds` property represents the structural coordinates of a folder type relative to the project root. Each integer in the array corresponds to the zero-based index of a folder within its parent's ``HarnessKit/PathFolder/folders`` collection.

This property is critical for **programmatic navigation**, especially on **tvOS**. Since tvOS lacks a touch screen, HarnessKit uses these indices to calculate exactly how many "remote-down" and "select" events are required to navigate through the hierarchy to reach a specific navigation level during UI tests.

> Important: All members of the ``HarnessKit/PathFolder`` protocol must be accessed on the **Main Actor**.

### Path Resolution

The value of `pathIds` is automatically calculated based on the ``HarnessKit/PathFolder/ParentSection`` typealias:

*   **Root Folders**: If the parent is a ``HarnessKit/PathProject``, the path is a single-element array containing the folder's index in the project's `folders` list.
*   **Nested Folders**: If the parent is another ``HarnessKit/PathFolder``, the path appends the current folder's index to the parent's `pathIds`.

### Reproducible Hierarchy Example

The following example demonstrates a full Project -> Folder -> Case hierarchy and shows how the static `pathIds` are derived.

@TabNavigator {
    @Tab("Implementation") {
        ```swift
        import HarnessKit
        import SwiftUI

        // 1. Define the Project Root
        enum ComponentProject: PathProject {
            static let name = "Main Gallery"
            static let folders: [any PathFolder.Type] = [
                UIElementsFolder.self // Index 0
            ]
        }

        // 2. Define a Top-Level Folder
        enum UIElementsFolder: PathFolder {
            typealias ParentSection = ComponentProject
            static let name = "UI Elements"
            static let folders: [any PathFolder.Type] = [
                ButtonsFolder.self // Index 0 in UIElementsFolder
            ]
        }

        // 3. Define a Leaf Folder with Cases
        enum ButtonsFolder: Int, PathFolder {
            typealias ParentSection = UIElementsFolder
            static let name = "Buttons"
            
            case primary = 0
            case secondary = 1
            
            var description: String { String(describing: self) }
            var view: some View { Text(description) }
        }
        ```
    }
    @Tab("Resolved Paths") {
        ```swift
        // Static property resolution (the index path to the FOLDER TYPE)
        
        UIElementsFolder.pathIds 
        // Returns: [0]
        
        ButtonsFolder.pathIds    
        // Returns: [0, 0]
        ```
    }
}

## Navigation Details

| Property | Type | Description |
| :--- | :--- | :--- |
| `pathIds` | `[Int]` | The ordered sequence of indices from the project root to this folder. |
| `nameComponents` | `[String]` | The ordered list of display names from the project root to this folder. |
| `namePath` | `String` | A slash-separated string representation of the full name path. |

> Tip: To get the path for a specific enum *case* (instance), use the instance property version of ``HarnessKit/PathFolder/pathIds``.

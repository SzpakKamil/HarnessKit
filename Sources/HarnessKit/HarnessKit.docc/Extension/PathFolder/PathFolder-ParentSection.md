# ``HarnessKit/PathFolder/ParentSection``

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

The type that contains this folder — either a ``PathProject`` or another ``PathFolder``.

## Overview

Set via `typealias` in every conforming type, the `ParentSection` associated type establishes the navigation relationship between folders and projects. This relationship is foundational to how HarnessKit calculates hierarchical metadata and navigates through the view tree.

### Path Resolution Logic

HarnessKit uses `ParentSection` to select the correct conditional extension for path-building. By specifying the parent, you enable the framework to automatically walk up the tree and compute:

1.  **Integer Identifiers**: The sequence of indices that uniquely identifies a folder or case within the hierarchy (``PathFolder/pathIds``).
2.  **Name Components**: The ordered list of display names from the project root down to the current level (``PathFolder/nameComponents``).
3.  **Name Path**: A slash-joined string representation of the full path, useful for accessibility identifiers (``PathFolder/namePath``).

## Implementation Requirements

The following table describes how `ParentSection` should be set based on the folder's position in the hierarchy:

| Parent Type | Hierarchy Level | Implementation Example |
| :--- | :--- | :--- |
| ``PathProject`` | Top-level | `typealias ParentSection = MyProject` |
| ``PathFolder`` | Nested | `typealias ParentSection = MyParentFolder` |

## Examples

### Full Reproducible Hierarchy
This example demonstrates a complete HarnessKit hierarchy: a Project containing a Folder, which in turn contains a Sub-Folder with navigable cases.

```swift
import HarnessKit
import SwiftUI

// 1. The Project (Root)
// Defines the top-level entry point for the harness.
enum MyProject: PathProject {
    static let name = "Demo App"
    static let folders: [any PathFolder.Type] = [MainFolder.self]
}

// 2. The Main Folder (Directly under Project)
// Sets ParentSection to MyProject to sit at the root level.
enum MainFolder: PathFolder {
    typealias ParentSection = MyProject 
    static let name = "Components"
    static let folders: [any PathFolder.Type] = [ButtonsFolder.self]
    
    // An optional info case
    case generalInfo
    
    var description: String { "Overview" }
    var view: some View { Text("Component Library Overview") }
}

// 3. The Sub-Folder (Nested under another Folder)
// Sets ParentSection to MainFolder. This folder is typically an Int enum
// to support remote-based navigation on platforms like tvOS.
enum ButtonsFolder: Int, PathFolder {
    typealias ParentSection = MainFolder
    static let name = "Buttons"
    
    case primary = 0
    case secondary = 1
    
    var description: String {
        switch self {
        case .primary: return "Primary Action"
        case .secondary: return "Secondary Action"
        }
    }
    
    var view: some View {
        Button(description) { }
            .buttonStyle(.borderedProminent)
    }
}

// 4. Rendering the Hierarchy
struct HarnessApp: App {
    var body: some Scene {
        WindowGroup {
            // Provide the root project as the generic parameter.
            HarnessView<MyProject>()
        }
    }
}
```

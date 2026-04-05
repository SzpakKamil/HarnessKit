# ``HarnessKit/PathFolder/nameComponents``

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

The ordered display-name components from the project root to this folder type.

## Overview

This static property provides a breadcrumb-style array of strings representing the navigation path to a specific folder. Each element in the array corresponds to the `name` property of a type in the hierarchy, starting from the folder directly under the root project.

HarnessKit uses these name components to identify and navigate to a folder within the application's view hierarchy. During UI testing, the `navigate(app:)` method from the `HarnessKitTesting` module iterates through this array to tap or click each navigation level by its display name.

### Path Construction

The array is built recursively by prepending the parent's name components to the current folder's name:

- **Root Folders**: For a folder sitting directly under a ``PathProject``, this array contains exactly one element: the folder's own `name`.
- **Nested Folders**: For sub-folders, this property appends the folder's `name` to the `nameComponents` of its `ParentSection`.

## Examples

### Defining a Full Hierarchy

The following example demonstrates how `nameComponents` is automatically derived through a full project hierarchy from a root project down to a nested folder with specific cases.

```swift
import SwiftUI
import HarnessKit

// 1. Define the Project Root
// The root project contributes an empty array of name components.
enum MyProject: PathProject {
    static let name = "My App"
    static let folders: [any PathFolder.Type] = [ComponentsFolder.self]
}

// 2. Define a Top-Level Folder
// nameComponents: ["Components"]
enum ComponentsFolder: PathFolder {
    typealias ParentSection = MyProject
    static let name = "Components"
    static let folders: [any PathFolder.Type] = [ButtonsFolder.self]
    
    // This folder acts as a container for sub-folders.
    case none
}

// 3. Define a Nested Folder with Cases
// nameComponents: ["Components", "Buttons"]
enum ButtonsFolder: Int, PathFolder {
    typealias ParentSection = ComponentsFolder
    static let name = "Buttons"
    
    case primary
    case secondary
    
    var description: String {
        switch self {
        case .primary: return "Primary Button"
        case .secondary: return "Secondary Button"
        }
    }
    
    var view: some View {
        Button(description) { }
            .padding()
    }
}

// Accessing the static property:
// print(ComponentsFolder.nameComponents) // ["Components"]
// print(ButtonsFolder.nameComponents)    // ["Components", "Buttons"]
```

> Note: For folders conforming to `RawRepresentable`, an instance-level `nameComponents` property also exists, which appends the specific case's name to this static array (e.g., `["Components", "Buttons", "primary"]`).

# ``HarnessKit/PathProject/nameComponents``

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

The ordered collection of display names representing the navigation path from the project root.

## Overview

For a type conforming to ``PathProject``, this property always returns an empty array because the project root has no parent navigation level. Within the broader HarnessKit hierarchy, this property serves as the foundation for path resolution:

*   **Inheritance**: Each nested ``PathFolder`` inherits the `nameComponents` array from its parent and appends its own display name.
*   **Testing**: The `PathFolderNavigation` utility uses these components to programmatically identify and tap through navigation levels (buttons or list rows) during UI tests.
*   **String Paths**: The ``PathProject/namePath`` property is derived by joining these components with a forward slash (`/`).

### Thread Safety
All members of ``PathProject`` are isolated to the `@MainActor`. Ensure that access to this property occurs on the main thread to comply with ``Sendable`` requirements and framework concurrency guarantees.

## Details

| Attribute | Type | Description |
| :--- | :--- | :--- |
| **Returns** | `[String]` | An empty array `[]` for the project root conformance. |
| **Isolation** | `@MainActor` | Guaranteed to be accessed on the main actor. |
| **Conformance** | `Sendable` | The parent protocol ensures thread-safe access. |

## Usage

The following example demonstrates a complete HarnessKit hierarchy (Project -> Folder -> Case) and how the `nameComponents` array is populated at each level.

```swift
import HarnessKit
import SwiftUI

// 1. Define the Project (The Root)
// The root nameComponents is always empty.
enum DesignSystemProject: PathProject {
    static let name = "Design System"
    static let folders: [any PathFolder.Type] = [ButtonsFolder.self]
}

// 2. Define a Folder (The Section)
// Appends its name to the project's components.
enum ButtonsFolder: PathFolder {
    typealias ParentSection = DesignSystemProject
    static let name = "Buttons"
    
    case primary, secondary

    var description: String {
        switch self {
        case .primary: return "Primary Action"
        case .secondary: return "Secondary Action"
        }
    }

    @ViewBuilder
    var view: some View {
        switch self {
        case .primary: Text("Primary Button Preview")
        case .secondary: Text("Secondary Button Preview")
        }
    }
}

// --- Path Verification ---
// DesignSystemProject.nameComponents            // []
// ButtonsFolder.nameComponents                 // ["Buttons"]
// ButtonsFolder.primary.nameComponents          // ["Buttons", "Primary Action"]
```

## Topics

### Navigation Metadata
- ``PathProject/name``
- ``PathProject/namePath``
- ``PathProject/pathIds``

### Related Symbols
- ``PathFolder/nameComponents``
- ``PathResolver``

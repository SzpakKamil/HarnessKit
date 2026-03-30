# ``HarnessKit/PathFolder/nameComponents``

@Metadata {
    @TitleHeading("Instance Property")
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

The complete ordered name path from the project root to this specific folder case.

## Overview

The `nameComponents` property provides an array of strings representing the navigation hierarchy required to reach a specific case within the harness. It is constructed by walking up the hierarchy to the root ``HarnessKit/PathProject`` and appending names at each level.

All members must be accessed on the main actor. This property is primarily utilized by the `HarnessKitTesting` module to facilitate automated UI testing, allowing the framework to tap through each navigation level by matching the display names in the array.

### Hierarchy Construction

The array is built incrementally through the following steps:

1.  **Project Root**: Starts with an empty array (the root title is not a navigable component).
2.  **Folder Type**: Appends the static `name` of the ``HarnessKit/PathFolder`` to the project's components.
3.  **Folder Case**: Appends the individual case name (derived from the Swift identifier) to the folder type's components.

For instance, an enum case `.primary` within a folder named `"Buttons"` results in `["Buttons", "primary"]`.

### Reflection Logic

The case name is dynamically resolved using Swift's `Mirror` API. This ensures that simple enums and those with associated values both return the correct identifier string (e.g., `"primary"`) without requiring manual string mapping from the developer.

## Details

| Property | Type | Description |
| :--- | :--- | :--- |
| `nameComponents` | `[String]` | The ordered list of display names from the project root down to this specific case. |

## Reproducible Example

This example demonstrates a complete `HarnessKit` hierarchy—from the root project to a specific leaf case—and how `nameComponents` captures that structure.

```swift
import HarnessKit
import SwiftUI

// 1. Define the Root Project
enum MyProject: PathProject {
    static let name = "Component Gallery"
    static let folders: [any PathFolder.Type] = [ButtonsFolder.self]
}

// 2. Define a Folder within the Project
enum ButtonsFolder: Int, PathFolder {
    typealias ParentSection = MyProject
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
        Text(description)
    }
}

// 3. Access the nameComponents property
@MainActor
func printPath() {
    // Accessing the instance-level nameComponents
    let path = ButtonsFolder.primary.nameComponents
    
    print(path) 
    // Output: ["Buttons", "primary"]
}
```

## Topics

### Related Path Properties
- ``HarnessKit/PathFolder/namePath``
- ``HarnessKit/PathFolder/pathIds``

### Resolution Helpers
- ``HarnessKit/PathFolder/names(for:)``

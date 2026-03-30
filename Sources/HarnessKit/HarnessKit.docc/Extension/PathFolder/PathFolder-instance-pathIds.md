# ``HarnessKit/PathFolder/pathIds``

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

The complete ordered integer path from the project root to this specific case.

## Overview

The `pathIds` property provides a unique numerical identifier for a specific navigation leaf (enum case) in the harness hierarchy. It is constructed by appending the case's `rawValue` to the static `pathIds` of the containing ``HarnessKit/PathFolder``.

This path is primarily used by the internal ``HarnessKit/PathFolder/ids(for:)`` resolver and for programmatic navigation on platforms like tvOS. On tvOS, the Siri Remote utilizes these indices to navigate through the list-based UI by counting the exact number of directional presses needed to reach a specific row.

> Important: This property must be accessed on the **Main Actor**.

### Requirements

To access this instance-level property, the ``HarnessKit/PathFolder`` must conform to `RawRepresentable` with a `RawValue` of `Int`. This enables the framework to map enum cases to their corresponding row indices automatically.

### Reproducible Example

Below is a complete implementation showing a reproducible hierarchy from the project root down to a specific case.

@TabNavigator {
    @Tab("Usage") {
        ```swift
        import HarnessKit
        import SwiftUI

        // 1. Define the Project Root
        enum DemoProject: PathProject {
            static let name = "Component Demo"
            static let folders: [any PathFolder.Type] = [ButtonFolder.self]
        }

        // 2. Define a Folder (Nested under Project)
        // Conformance to Int is required for instance-level pathIds
        enum ButtonFolder: Int, PathFolder {
            typealias ParentSection = DemoProject
            static let name = "Buttons"
            
            case primary    = 0
            case secondary  = 1
            
            var view: some View {
                Text(description)
            }
            
            var description: String { "\(self)" }
        }

        // 3. Access the pathIds on the Main Actor
        @MainActor
        func printPath() {
            let path = ButtonFolder.secondary.pathIds
            // Result: [0, 1]
            // [0] -> Index of ButtonFolder in DemoProject.folders
            // [1] -> rawValue of .secondary
            print(path)
        }
        ```
    }
}

## Implementation Details

The path is built recursively by walking up the `ParentSection` chain until the root ``HarnessKit/PathProject`` is reached.

| Level | Component Source | Description | Example Value |
| :--- | :--- | :--- | :--- |
| **Project** | ``HarnessKit/PathProject`` | The root of the hierarchy; always returns an empty array. | `[]` |
| **Folder** | ``HarnessKit/PathFolder/pathIds`` | The static path to the folder type within its parent. | `[0]` |
| **Case** | `self.rawValue` | The specific index of the navigable leaf. | `1` |
| **Final** | **`pathIds`** | The merged sequence identifying the exact navigation target. | **`[0, 1]`** |

## Topics

### Related Path Symbols
- ``HarnessKit/PathFolder/nameComponents-6l0zs``
- ``HarnessKit/PathFolder/namePath-508su``
- ``HarnessKit/PathFolder/ids(for:)``

### Navigation Components
- ``HarnessKit/PathProject``
- ``HarnessKit/HarnessView``

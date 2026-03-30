# ``HarnessKit/PathFolder/namePath-508su``

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

A slash-separated string representation of the full display-name path from the project root to this specific case.

## Overview

The `namePath` property provides a unique, human-readable string identifier for a specific ``HarnessKit/PathFolder`` case. It is constructed by joining all elements of the instance-level ``HarnessKit/PathFolder/nameComponents-768p0`` array with a forward slash (`/`).

This property is automatically available to any `PathFolder` conforming to `RawRepresentable` with an `Int` raw value. It is particularly useful for:

- **Accessibility Identifiers**: Providing a structured, stable ID for views during UI testing.
- **Debugging**: Identifying the exact position of a view within a complex navigation tree.
- **Navigation Logging**: Tracking user movement through the harness hierarchy.

### Hierarchy Example

To generate a valid `namePath`, you must define a complete hierarchy from the root project down to the individual enum cases.

```swift
import HarnessKit
import SwiftUI

// 1. Define the Project (The Root)
enum DesignSystemProject: PathProject {
    static let name = "Design System"
    static let folders: [any PathFolder.Type] = [ComponentsFolder.self]
}

// 2. Define the Folder (A Section)
enum ComponentsFolder: Int, PathFolder {
    typealias ParentSection = DesignSystemProject
    static let name = "Components"

    case buttons
    case toggles

    var description: String {
        switch self {
        case .buttons: "Buttons"
        case .toggles: "Toggles"
        }
    }

    var view: some View {
        Text("Component View")
    }
}

// 3. Access the path
// The instance property joins "Components" (folder name) and "buttons" (case name)
let identifier = ComponentsFolder.buttons.namePath
// Result: "Components/buttons"
```

## See Also

- ``HarnessKit/PathFolder/nameComponents-768p0``
- ``HarnessKit/PathProject/namePath``
- ``HarnessKit/PathFolder/namePath-926y7``

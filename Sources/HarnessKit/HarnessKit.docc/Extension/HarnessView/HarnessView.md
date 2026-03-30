# ``HarnessKit/HarnessView``

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
    @AutomaticTitleHeading(enabled)
    @AutomaticSeeAlso(disabled)
    @AutomaticArticleSubheading(disabled)
}

The root view of a ``HarnessKit`` harness app.

## Overview

``HarnessView`` provides a structured navigation interface for SwiftUI demo apps and component previews. By providing a type that conforms to ``PathProject`` as a generic parameter, the view automatically generates a hierarchical list of folders and navigable cases.

All members of ``HarnessView`` must be accessed on the **main actor**.

### Navigation Hierarchy

The view builds a `NavigationStack` (on iOS 16+, macOS 13+, and tvOS 16+) or a `NavigationView` (on older OS versions) whose root is a list of all top-level folders defined in the project. The navigation title of the root list is derived from ``PathProject/name``.

Each row in the root list corresponds to a folder defined in ``PathProject/folders``. Selecting a folder pushes a new level of sub-folders or a final view case, recursively building the navigation tree.

### Example Hierarchy

To render a harness, define a ``PathProject``, a ``PathFolder``, and pass the project to ``HarnessView``.

```swift
import SwiftUI
import HarnessKit

// 1. Define the project root
enum MyProject: PathProject {
    static let name = "Design System"
    static let folders: [any PathFolder.Type] = [ComponentsFolder.self]
}

// 2. Define a folder for components
enum ComponentsFolder: PathFolder {
    typealias ParentSection = MyProject
    static let name = "Components"
    
    // Each case represents a navigable leaf
    case buttons, labels
    
    var description: String {
        switch self {
        case .buttons: return "Buttons Gallery"
        case .labels: return "Labels Gallery"
        }
    }
    
    @ViewBuilder
    var view: some View {
        switch self {
        case .buttons: Text("Button Gallery View")
        case .labels: Text("Label Gallery View")
        }
    }
}

// 3. Root Application View
struct HarnessApp: App {
    var body: some Scene {
        WindowGroup { 
            HarnessView<MyProject>() 
        }
    }
}
```

## Parameters

| Name | Type | Description |
| :--- | :--- | :--- |
| `Project` | `PathProject` | The configuration type that defines the navigation tree. |

## Topics

### Initializers

- ``init()``

### Related Types

- ``PathProject``
- ``PathFolder``

# ``HarnessKit/PathProject``

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

The root of a ``HarnessKit`` view hierarchy.

## Overview

Conform a type (typically a caseless enum) to ``PathProject`` to define the top-level entry point for your harness app. ``PathProject`` groups one or more ``PathFolder`` sections and provides the name shown at the navigation root.

> Note: All members must be accessed on the main actor. Conforms to `Sendable`; all static properties must be safe to access from the main actor.

### Building the Tree
The hierarchy in `HarnessKit` is structured as a tree where a ``PathProject`` is the root, followed by nested ``PathFolder`` types, and finally individual cases representing leaf views. This structure allows ``HarnessView`` to automatically generate a navigation-based UI for browsing components.

### Automated Navigation
Internal properties like `pathIds` and `nameComponents` are used by the framework to resolve the location of any view within the tree. This enables features like programmatic navigation and automated UI testing using `HarnessKitTesting`. For full support on all platforms, including tvOS remote navigation, folders should be defined as `Int`-based enums conforming to `RawRepresentable`.

### Property Grid

| Name | Type | Description |
| :--- | :--- | :--- |
| `name` | `String` | The display name used by ``HarnessView`` as the navigation title for the top-level list. |
| `folders` | `[any PathFolder.Type]` | The ordered collection of metatypes conforming to ``PathFolder`` that populate the root list. |
| `pathIds` | `[Int]` | Internal: The sequence of indices identifying the project's position. Always `[]` for the root. |
| `nameComponents` | `[String]` | Internal: The display-name components from the project root down. Always `[]` for the root. |
| `namePath` | `String` | Internal: A slash-separated string representation of the full name path. Defaults to `""` for the root. |

### Example

The following example demonstrates a full ``HarnessKit`` hierarchy: a project containing a single folder with two navigable cases. This implementation is reproducible and serves as a blueprint for your own design systems.

```swift
import HarnessKit
import SwiftUI

// 1. The Project (Root)
// Defines the entry point for the harness application.
enum UIProject: PathProject {
    static let name = "Design System"
    static let folders: [any PathFolder.Type] = [
        ButtonsFolder.self
    ]
}

// 2. The Folder (Section)
// Groups related components and defines their navigation behavior.
// Conforming to Int-raw-value enum enables tvOS remote navigation.
enum ButtonsFolder: Int, PathFolder {
    // Links this folder back to its parent project.
    typealias ParentSection = UIProject
    
    static let name = "Buttons"
    
    // 3. The Cases (Leaves)
    // Each case represents a unique view to be showcased.
    case primary
    case secondary
    
    // The label displayed in the navigation list for this option.
    var description: String {
        switch self {
        case .primary: return "Primary Action"
        case .secondary: return "Secondary Action"
        }
    }
    
    // The SwiftUI view presented when this case is selected.
    @ViewBuilder
    var view: some View {
        switch self {
        case .primary:
            Button("Primary") {}
                .buttonStyle(.borderedProminent)
        case .secondary:
            Button("Secondary") {}
                .buttonStyle(.bordered)
        }
    }
}
```

## Topics

### Configuration
@Links(visualStyle: list) {
    - ``name``
    - ``folders``
}

### Internal Path Properties
@Links(visualStyle: list) {
    - ``pathIds``
    - ``nameComponents``
    - ``namePath``
}

### Supporting Views
@Links(visualStyle: list) {
    - ``HarnessView``
}

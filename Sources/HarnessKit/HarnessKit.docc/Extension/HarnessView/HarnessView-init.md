# ``HarnessKit/HarnessView/init()``

Initializes a root harness view using a defined `PathProject` hierarchy.

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

Creates a `HarnessView` that automatically builds a navigation hierarchy based on the structure provided by the `Project` generic type.

## Overview

The `HarnessView` initializer requires no explicit parameters. Instead, it derives the entire navigation structure—including folders, sub-folders, and individual view cases—from the ``PathProject`` type passed as a generic parameter to the parent struct.

All members of ``HarnessView`` must be accessed on the **main actor**.

### Navigation Container

When initialized, `HarnessView` constructs a platform-appropriate navigation container to host your hierarchy:
- **Modern OS (iOS 16+, macOS 13+, tvOS 16+)**: Uses a `NavigationStack` for optimized performance and support for programmatic navigation.
- **Legacy OS**: Falls back to `NavigationView` on older platform versions (iOS 14/15, macOS 11/12).

The root of this container is a `List` generated from the ``PathProject/folders`` property of the generic `Project` type.

### Generic Requirements

| Name | Type | Description |
| :--- | :--- | :--- |
| `Project` | ``PathProject`` | The type defining the root of the harness hierarchy, providing the navigation title and top-level folders. |

## Usage

To render a harness, you must define a full hierarchy consisting of a project root, navigation folders, and individual leaf cases.

```swift
import SwiftUI
import HarnessKit

// 1. The Project Root
enum MyDesignSystem: PathProject {
    static let name = "Design System"
    static let folders: [any PathFolder.Type] = [
        ComponentsFolder.self
    ]
}

// 2. The Navigation Folder
enum ComponentsFolder: Int, PathFolder {
    typealias ParentSection = MyDesignSystem
    static let name = "Components"
    
    // 3. The Leaf Case
    case buttons
    case labels
    
    var description: String {
        switch self {
        case .buttons: return "Buttons"
        case .labels: return "Labels"
        }
    }
    
    @ViewBuilder
    var view: some View {
        switch self {
        case .buttons:
            Button("Primary Action") { }
                .buttonStyle(.borderedProminent)
        case .labels:
            Text("Content Label")
        }
    }
}

// 4. Initialization
@main
struct DesignSystemApp: App {
    var body: some Scene {
        WindowGroup {
            // HarnessView derives all structure from MyDesignSystem
            HarnessView<MyDesignSystem>()
        }
    }
}
```

## See Also

- ``HarnessKit/HarnessView``
- ``HarnessKit/PathProject``
- ``HarnessKit/PathFolder``

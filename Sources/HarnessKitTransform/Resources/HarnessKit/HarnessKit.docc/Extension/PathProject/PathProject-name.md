# ``HarnessKit/PathProject/name``

@Metadata {
    @SupportedLanguage(swift)
    @Available(iOS, introduced: "14.0")
    @Available(macOS, introduced: "11.0")
    @Available(tvOS, introduced: "14.0")
    @Available(watchOS, introduced: "10.0")
    @Available(visionOS, introduced: "1.0")
    @DocumentationExtension(mergeBehavior: override)
}

@Options {
    @AutomaticArticleSubheading(disabled)
}

The display name shown as the navigation title of the root list.

## Overview

The `name` property defines the human-readable identifier for the entire harness project. When you initialize a ``HarnessView`` with your ``PathProject`` conformance, this value is automatically applied as the `navigationTitle` for the root-level list.

It should be a short, distinct string that identifies the collection of views, such as "Component Library" or "UIKit Previews".

### Mandatory Main Actor Access
As the ``PathProject`` protocol is marked with `@MainActor`, the `name` property must be accessed on the main actor. This ensures thread-safe access when building the navigation hierarchy within SwiftUI.

### Reproducible Hierarchy Example

To correctly implement a project name within a full hierarchy, define your root project, a folder section, and the individual navigable cases.

@TabNavigator {
    @Tab("Harness Structure") {
        ```swift
        import HarnessKit
        import SwiftUI

        // 1. The Project Root
        // HarnessView renders this 'name' as its navigation title.
        enum MyProject: PathProject {
            static let name = "Design System"
            static let folders: [any PathFolder.Type] = [ButtonsFolder.self]
        }

        // 2. The Folder Section
        enum ButtonsFolder: Int, PathFolder {
            typealias ParentSection = MyProject
            static let name = "Buttons"
            
            case primary
            case secondary
        }

        // 3. The Leaf Case
        extension ButtonsFolder {
            var description: String {
                switch self {
                case .primary: return "Primary Action"
                case .secondary: return "Secondary Action"
                }
            }
            
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
    }
    @Tab("App Entry") {
        ```swift
        import SwiftUI
        import HarnessKit

        @main
        struct HarnessApp: App {
            var body: some Scene {
                WindowGroup {
                    // Renders the "Design System" project root.
                    HarnessView<MyProject>()
                }
            }
        }
        ```
    }
}

## Property Details

| Name | Type | Description |
| :--- | :--- | :--- |
| `name` | `String` | The string displayed in the navigation bar at the project root. |

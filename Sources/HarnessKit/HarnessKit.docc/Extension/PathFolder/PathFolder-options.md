# ``HarnessKit/PathFolder/options``

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

All navigable case instances of this folder, in declaration order.

## Overview

The `options` property defines the set of enum cases that will be rendered as navigable rows within a `HarnessFolderView`. By default, this property returns all cases of the conforming enum via its `CaseIterable` conformance.

### Customizing Visibility

While most folders will use the default `Array(allCases)` implementation, you can override this property to:
*   **Filter Options**: Provide a subset of cases to hide "work-in-progress" views or internal utilities from the UI.
*   **Reorder Items**: Change the display order of rows without modifying the underlying enum declaration order.
*   **Static Grouping**: Return a fixed list of instances that might not represent the entire enum space.

The framework converts the `CaseIterable` sequence into a plain array of `[any PathFolder]` existentials, allowing `HarnessView` to iterate and render them regardless of their concrete associated types.

### Implementation Requirements

| Requirement | Description |
| :--- | :--- |
| **Type** | `[any PathFolder]` |
| **Default** | `Array(allCases)` |
| **Context** | Must be accessed on the `@MainActor`. |

## Usage

The following example demonstrates a full HarnessKit hierarchy where a folder overrides `options` to exclude a specific "experimental" case from the navigation list.

```swift
import SwiftUI
import HarnessKit

// 1. Root Project Configuration
enum DemoProject: PathProject {
    static let name = "Design System"
    static let folders: [any PathFolder.Type] = [
        ButtonsFolder.self
    ]
}

// 2. Folder Configuration with Options Override
enum ButtonsFolder: Int, PathFolder {
    typealias ParentSection = DemoProject
    static let name = "Buttons"

    case primary
    case secondary
    case experimental // We want to hide this from the production harness

    // Override options to provide a custom ordered subset
    static var options: [any PathFolder] {
        [.primary, .secondary]
    }

    var description: String {
        switch self {
        case .primary: "Primary Action"
        case .secondary: "Secondary Action"
        case .experimental: "Experimental Feature"
        }
    }

    @ViewBuilder
    var view: some View {
        switch self {
        case .primary:
            Button("Primary") { }.buttonStyle(.borderedProminent)
        case .secondary:
            Button("Secondary") { }.buttonStyle(.bordered)
        case .experimental:
            Text("Coming Soon...")
        }
    }
}
```

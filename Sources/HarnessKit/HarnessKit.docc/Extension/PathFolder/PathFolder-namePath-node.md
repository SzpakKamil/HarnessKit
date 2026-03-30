# ``HarnessKit/PathFolder/namePath(for:)``

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

Returns a slash-joined string representation of the full hierarchical path from the project root to a specific folder case.

## Overview

This method provides a unique string identifier for a specific ``PathFolder`` case by joining its hierarchical name components with a forward slash (`/`). It is a convenience resolver that allows you to obtain the full path without needing an instance of the folder if you have the case available.

All members of the navigation hierarchy must be accessed on the **main actor**.

### Key Use Cases

- **Accessibility Identifiers**: Automatically generate stable and descriptive `accessibilityIdentifier` values for views.
- **UI Automation**: Use the generated path to target specific elements in `XCTest` suites.
- **Deep Linking**: Generate identifiers that can be used to resolve navigation state from external sources.
- **Logging & Debugging**: Print clear, human-readable breadcrumbs of the current navigation state.

### Reproducible Hierarchy Example

To resolve a path, you must define a complete hierarchy starting from a ``PathProject`` down to a ``PathFolder`` case.

```swift
import HarnessKit
import SwiftUI

// 1. Define the root project of your app
enum DesignSystem: PathProject {
    static let name = "Design System"
    static let folders: [any PathFolder.Type] = [ComponentsFolder.self]
}

// 2. Define a navigable folder within the project
// Note: Conforming to Int-based RawRepresentable is required for path resolution.
enum ComponentsFolder: Int, PathFolder {
    typealias ParentSection = DesignSystem
    static let name = "Components"

    case buttons
    case toggles
    case sliders

    var description: String {
        switch self {
        case .buttons: "Action Buttons"
        case .toggles: "Switch Controls"
        case .sliders: "Value Sliders"
        }
    }

    @ViewBuilder
    var view: some View {
        Text(description)
    }
}

// 3. Resolve the full path for a specific case
let path = ComponentsFolder.namePath(for: .buttons)
// Result: "Components/buttons"
```

## Parameters

| Name | Type | Description |
| :--- | :--- | :--- |
| `node` | `N` | A specific enum case of a type conforming to ``PathFolder`` and `RawRepresentable` with `Int` raw values. |

## Returns

A `String` containing the slash-separated display names of each navigation level, starting from the folder's name and ending with the case's identifier.

## Topics

### Path Resolvers
- ``names(for:)``
- ``ids(for:)``
- ``namePath(forType:)``
- ``names(forType:)``

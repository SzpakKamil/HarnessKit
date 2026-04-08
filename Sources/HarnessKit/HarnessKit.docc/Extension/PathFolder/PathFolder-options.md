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

The navigable case instances rendered as rows in the navigation list.

## Overview

Return every case you want visible in the harness UI. The framework iterates `options` to build the navigation list for this folder, so the order and contents of the array control what users see.

Return a subset to hide work-in-progress cases. Return a reordered array to change the display order without touching the enum declaration.

### Implementation Requirements

| Requirement | Description |
| :--- | :--- |
| **Type** | `[any PathFolder]` |
| **Context** | Must be accessed on the `@MainActor`. |

## Usage

```swift
import SwiftUI
import HarnessKit

enum DemoProject: PathProject {
    static let name = "Design System"
    static let folders: [any PathFolder.Type] = [ButtonsFolder.self]
}

enum ButtonsFolder: Int, PathFolder {
    typealias ParentSection = DemoProject
    static let name = "Buttons"

    case primary
    case secondary
    case experimental

    // Return only the cases you want displayed.
    static var options: [any PathFolder] {
        [Self.primary, Self.secondary]
    }

    var description: String {
        switch self {
        case .primary:      "Primary Action"
        case .secondary:    "Secondary Action"
        case .experimental: "Experimental Feature"
        }
    }

    @ViewBuilder
    var view: some View {
        switch self {
        case .primary:      Button("Primary") {}.buttonStyle(.borderedProminent)
        case .secondary:    Button("Secondary") {}.buttonStyle(.bordered)
        case .experimental: Text("Coming Soon...")
        }
    }
}
```

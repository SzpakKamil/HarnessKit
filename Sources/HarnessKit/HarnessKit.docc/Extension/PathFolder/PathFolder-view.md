# ``HarnessKit/PathFolder/view``

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

The SwiftUI view presented when the user navigates to this option.

## Overview

Implement this property to return the preview or component view associated with a specific folder case. This is the "leaf" of the navigation tree—the actual content the user sees after drilling down through the project folders.

The `view` property is decorated with `@ViewBuilder`, allowing you to use standard SwiftUI branching logic (like `if` or `switch`) to return different view types for different cases without needing explicit `return` statements or manual type-erasure.

### Type Erasure and AnyView

While `PathFolder` cases often return different concrete view types, you **never need to wrap your views in `AnyView`**. HarnessKit handles type-erasure internally using a private helper during the rendering of the navigation stack. This keeps your implementation clean and preserves SwiftUI's optimization capabilities.

## Usage

The following example demonstrates a complete HarnessKit hierarchy, showing how the `view` property connects a specific enum case to its visual representation.

```swift
import SwiftUI
import HarnessKit

// 1. Define the Root Project
enum MyProject: PathProject {
    static let name = "Component Gallery"
    static let folders: [any PathFolder.Type] = [ButtonsFolder.self]
}

// 2. Define a Folder and its Cases
enum ButtonsFolder: Int, PathFolder {
    typealias ParentSection = MyProject
    static let name = "Buttons"
    
    case primary
    case secondary
    case destructive

    var description: String {
        switch self {
        case .primary: "Primary Action"
        case .secondary: "Secondary Action"
        case .destructive: "Delete / Reset"
        }
    }

    // 3. Implement the View property for each case
    @ViewBuilder
    var view: some View {
        switch self {
        case .primary:
            Button("Primary") { }.buttonStyle(.borderedProminent)
        case .secondary:
            Button("Secondary") { }.buttonStyle(.bordered)
        case .destructive:
            Button("Delete", role: .destructive) { }
        }
    }
}
```

## Details

| Attribute | Value |
| :--- | :--- |
| **Inferred Type** | `Content` (conforming to `View`) |
| **Default Value** | `EmptyView()` |
| **Execution Context** | `@MainActor` |

## Topics

### Navigation Content
- ``HarnessKit/PathFolder/description``
- ``HarnessKit/PathFolder/Content``

### Hierarchy
- ``HarnessKit/PathProject``
- ``HarnessKit/PathFolder/ParentSection``

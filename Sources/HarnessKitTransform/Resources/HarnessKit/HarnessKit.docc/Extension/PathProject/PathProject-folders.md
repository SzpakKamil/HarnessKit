# ``HarnessKit/PathProject/folders``

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

The ordered list of top-level folder types that belong to this project.

## Overview

Each element in this array is a metatype conforming to ``PathFolder``. ``HarnessView`` iterates through this collection to build the root navigation list of your harness application. 

The order of elements in this array directly determines the display order of the top-level sections in the user interface. 

> [!IMPORTANT]
> All members of `PathProject` must be accessed on the `@MainActor`.

### Implementation Details

By default, this property returns an empty array. You must override it to populate your project with folders. Conformances typically use a caseless enum as the project root and provide an array of folder metatypes.

- **Return Type**: `[any PathFolder.Type]`
- **Default Value**: `[]`
- **Concurrency**: Requires execution on the `@MainActor`.

## Example

The following example demonstrates a complete hierarchy from the project root down to individual navigable cases.

```swift
import SwiftUI
import HarnessKit

// 1. Define the Project (The Root)
// Use a caseless enum to represent the project entry point.
enum ComponentLibrary: PathProject {
    static let name = "Component Library"
    
    // Provide the top-level folders that will appear in the root list.
    static var folders: [any PathFolder.Type] {
        [ButtonsFolder.self]
    }
}

// 2. Define a Folder (The Section)
// Conform an enum (typically Int-raw-value) to PathFolder.
enum ButtonsFolder: Int, PathFolder {
    // Link back to the parent project or another folder.
    typealias ParentSection = ComponentLibrary
    static let name = "Buttons"
    
    // 3. Define the Cases (Navigable Options)
    // Each case represents a leaf view in the navigation tree.
    case primary
    case secondary
    
    /// The label displayed in the navigation list row for this option.
    var description: String {
        switch self {
        case .primary: return "Primary Action"
        case .secondary: return "Secondary Action"
        }
    }
    
    /// The SwiftUI view presented when the user navigates to this option.
    @ViewBuilder
    var view: some View {
        switch self {
        case .primary: 
            Button("Primary") { }
                .buttonStyle(.borderedProminent)
        case .secondary: 
            Button("Secondary") { }
                .buttonStyle(.bordered)
        }
    }
}

// 4. Render the Harness
// Pass your PathProject to HarnessView in your App scene.
struct LibraryApp: App {
    var body: some Scene {
        WindowGroup {
            HarnessView<ComponentLibrary>()
        }
    }
}
```

## See Also

- ``HarnessKit/PathProject/name``
- ``HarnessKit/PathFolder``
- ``HarnessKit/HarnessView``

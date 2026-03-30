# ``HarnessKit/PathFolder/folders``

The ordered list of sub-folder types nested inside this folder.

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

## Overview

Use this property to define the nesting structure of your navigation hierarchy. When a `PathFolder` contains other folders, `HarnessView` automatically renders each element in this array as a `NavigationLink` row. These sub-folder rows are always displayed before the individual option rows of the current folder.

### Implementation Details

- **Default Value**: Defaults to an empty array `[]` via the base protocol extension.
- **Leaf Folders**: For leaf folders that contain only navigable cases and no sub-folders, leave this property at its default or explicitly set it to `[]`.
- **Main Actor**: All members of `PathFolder`, including `folders`, must be accessed on the main actor.

## Example

The following example demonstrates a full hierarchy where a root project contains a parent folder, which in turn nests a sub-folder using the `folders` property.

```swift
import HarnessKit
import SwiftUI

// 1. Project Level: The root of the hierarchy
enum MyProject: PathProject {
    static let name = "My App"
    static let folders: [any PathFolder.Type] = [MainFolder.self]
}

// 2. Folder Level (Parent): Nests another folder using 'folders'
enum MainFolder: PathFolder {
    typealias ParentSection = MyProject
    static let name = "Components"
    
    // Nesting the ButtonsFolder sub-section
    static let folders: [any PathFolder.Type] = [ButtonsFolder.self]
}

// 3. Folder Level (Child/Leaf): Contains specific navigable cases
enum ButtonsFolder: Int, PathFolder {
    typealias ParentSection = MainFolder
    static let name = "Buttons"
    
    case primary, secondary
    
    // Provide labels for the navigation list
    var description: String {
        switch self {
        case .primary: "Primary Action"
        case .secondary: "Secondary Action"
        }
    }
    
    // Provide the destination view for each case
    var view: some View {
        switch self {
        case .primary: Text("Primary Button Preview")
        case .secondary: Text("Secondary Button Preview")
        }
    }
}
```

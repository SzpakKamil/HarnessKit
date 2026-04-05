# ``HarnessKit/PathFolder/name``

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

The display name used as the navigation title for this folder's list.

## Overview

The `name` property defines the human-readable string that identifies a ``PathFolder`` within the harness. This value serves two primary purposes in the user interface:

1.  **Navigation Title**: When a user navigates into a folder, this string is applied as the `.navigationTitle` of the destination list.
2.  **Breadcrumbs**: It contributes to the generated ``nameComponents`` and ``namePath``, which are used for path resolution and UI testing.

Provide a short, human-readable string. HarnessView uses this value to ensure that the user always has clear context of their current location within the project's hierarchy.

> Note: All members of ``PathFolder``, including this static property, must be accessed on the `@MainActor`.

### Implementation Requirements

| Name | Type | Description |
| :--- | :--- | :--- |
| `name` | `String` | A static property providing the display label for the navigation level. |

## Usage

To implement `name` correctly, you must define it within an enum conforming to ``PathFolder``. This enum must then be linked to a ``PathProject`` or another ``PathFolder``.

```swift
import HarnessKit
import SwiftUI

// 1. Define the Project Root
enum UIProject: PathProject {
    static let name = "Component Gallery"
    static let folders: [any PathFolder.Type] = [ButtonsFolder.self]
}

// 2. Define a Folder (Section)
enum ButtonsFolder: PathFolder {
    typealias ParentSection = UIProject
    
    // The property being documented
    static let name = "Buttons" 
    
    // 3. Define the Cases (Leaves)
    case primary, secondary
    
    var description: String {
        switch self {
        case .primary: "Primary Action"
        case .secondary: "Secondary Action"
        }
    }
    
    @ViewBuilder
    var view: some View {
        switch self {
        case .primary: Text("Primary Button Preview")
        case .secondary: Text("Secondary Button Preview")
        }
    }
}
```

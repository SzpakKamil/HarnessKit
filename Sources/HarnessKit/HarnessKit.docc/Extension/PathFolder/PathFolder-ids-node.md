# ``HarnessKit/PathFolder/ids(for:)``

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

Returns the complete integer path for a specific folder case.

## Overview

This static method calculates the sequence of indices required to navigate from the root ``HarnessKit/PathProject`` to a specific navigation leaf. It serves as a primary resolver for programmatic navigation, particularly on **tvOS**, where it provides the exact count of directional presses needed to reach a destination.

The method delegates to the instance-level `pathIds` property of the node. It recursively resolves the path by walking up the hierarchy through each ``HarnessKit/PathFolder/ParentSection``:
1.  **Folder Indices**: The index of each ancestor folder within its parent's `folders` array.
2.  **Case Index**: The `rawValue` of the target enum case, which forms the final element of the array.

### Reproducible Example

The following example demonstrates a complete HarnessKit hierarchy and how to resolve the path for a specific button preview.

```swift
import HarnessKit
import SwiftUI

// 1. Define the Root Project
enum DesignSystemProject: PathProject {
    static let name = "Design System"
    static let folders: [any PathFolder.Type] = [
        TypographyFolder.self, // Index 0
        ButtonsFolder.self     // Index 1
    ]
}

// 2. Define a Folder
enum ButtonsFolder: Int, PathFolder {
    typealias ParentSection = DesignSystemProject
    static let name = "Buttons"

    case primary      // rawValue 0
    case secondary    // rawValue 1
    case destructive  // rawValue 2

    @ViewBuilder
    var view: some View {
        switch self {
        case .primary: Text("Primary Button")
        case .secondary: Text("Secondary Button")
        case .destructive: Text("Destructive Button")
        }
    }
}

// 3. Resolve the path for the 'destructive' case
let path = ButtonsFolder.ids(for: .destructive)

// Result: [1, 2]
// - '1' corresponds to ButtonsFolder in DesignSystemProject.folders
// - '2' corresponds to the rawValue of .destructive
```

## Parameters

| Name | Type | Description |
| :--- | :--- | :--- |
| `node` | `N` | A specific enum case conforming to ``HarnessKit/PathFolder`` and `RawRepresentable<Int>`. |

## Return Value

An array of `Int` containing the ordered path indices from the project root to the specified case.

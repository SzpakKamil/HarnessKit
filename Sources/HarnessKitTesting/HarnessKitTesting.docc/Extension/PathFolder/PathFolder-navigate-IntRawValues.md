# ``HarnessKit/PathFolder/navigate(app:)-1ajjy``

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

Navigates to a specific folder case or leaf view in a running `XCUIApplication`.

## Overview

This method provides automated navigation to a specific component preview or leaf level in your harness. It is available for any enum conforming to `PathFolder` and `RawRepresentable` where `RawValue == Int`.

### Navigation Strategy

The navigation approach adapts based on the current platform to ensure reliability regardless of the input method:

| Platform | Navigation Mechanism | Strategy |
| :--- | :--- | :--- |
| **iOS / iPadOS** | Accessibility Labels | Taps through levels using labels; handles scrolling automatically by swiping. |
| **macOS** | Accessibility Labels | Clicks through levels using labels; handles scrolling via scroll views or page keys. |
| **tvOS** | Remote Focus | Uses `XCUIRemote` to press directional buttons and select by index. |
| **watchOS** | Accessibility Labels | Taps using Digital Crown rotation to scroll to the target if not visible. |

### Implementation Details for tvOS

On tvOS, navigation is performed entirely by index to avoid issues with focus and accessibility labels in complex lists. The framework calculates the path using `pathIds` and performs the following sequence:

1.  **Traverse Folders**: For each parent folder in the hierarchy, it sends the required number of `.down` presses (based on the folder's index in its parent) followed by `.select`.
2.  **Select Case**: It calculates the final row index as `Self.folders.count + self.rawValue`. It presses `.down` that many times to skip sub-folders and reach the target case, then sends `.select`.

> Tip: In tvOS list rows, sub-folder rows appear first (one per element in `folders`), followed by option rows in `rawValue` order. Ensure your `rawValue` matches the declaration order for predictable navigation.

> Note: This method is isolated to the `@MainActor`. Ensure it is called from the main thread, which is the default for `XCTestCase` methods in modern Swift.

## Parameters

| Name | Type | Description |
| :--- | :--- | :--- |
| `app` | `XCUIApplication` | The running application instance to perform navigation on. |

## Example

The following example demonstrates a full HarnessKit hierarchy—including Project, Folder, and Case—and shows how to navigate to a specific preview in a UI test.

```swift
import HarnessKit
import HarnessKitTesting
import SwiftUI
import XCTest

// 1. Define the Root Project
// Conform a caseless enum to PathProject to define the top-level entry point.
enum MyProject: PathProject {
    static let name = "My Component Gallery"
    static let folders: [any PathFolder.Type] = [
        ButtonsFolder.self
    ]
}

// 2. Define a Folder
// Conform an Int-raw-value enum to PathFolder for full platform support (including tvOS).
enum ButtonsFolder: Int, PathFolder {
    typealias ParentSection = MyProject
    static let name = "Buttons"

    case primary = 0
    case secondary = 1
    case destructive = 2

    var description: String {
        switch self {
        case .primary:     return "Primary Action"
        case .secondary:   return "Secondary Action"
        case .destructive: return "Destructive Action"
        }
    }

    @ViewBuilder
    var view: some View {
        switch self {
        case .primary:     Button("Primary") { }.buttonStyle(.borderedProminent)
        case .secondary:   Button("Secondary") { }.buttonStyle(.bordered)
        case .destructive: Button("Delete") { }.tint(.red)
        }
    }
}

// 3. UI Test Navigation
// Use the navigate(app:) method on a specific case instance.
final class HarnessUITests: XCTestCase {
    @MainActor
    func testNavigateToDestructiveButton() {
        let app = XCUIApplication()
        app.launch()

        // Navigates through: "My Component Gallery" -> "Buttons" -> "Destructive Action"
        ButtonsFolder.destructive.navigate(app: app)

        // Verification
        XCTAssertTrue(app.buttons["Delete"].exists)
    }
}
```

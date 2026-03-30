# ``HarnessKit/PathFolder/navigate(app:)-kwcb``

Navigates to the folder-level list view in a running `XCUIApplication`.

@Metadata {
    @SupportedLanguage(swift)
    @Available(iOS, introduced: "14.0")
    @Available(iPadOS, introduced: "14.0")
    @Available(macOS, introduced: "11.0")
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

This overload of `navigate(app:)` is used to reach a specific navigation level—a folder's list of options—within a HarnessKit hierarchy. It is specifically designed for types conforming to `PathFolder` that do not provide `Int` raw values.

Unlike the `RawRepresentable` overload, this method stops navigation at the folder list itself and does not attempt to select a specific case. This is ideal for UI tests that need to verify the contents of a folder or perform actions within a specific navigation section.

### How it Works

The navigation process follows a deterministic path-resolution strategy:
1. **Path Resolution**: It calls `PathFolder/names(forType:)` to obtain the ordered sequence of display names from the project root down to the target folder.
2. **Traversal**:
    - **iOS / watchOS / visionOS**: It iterates through the resolved names and uses the internal `tapButtonWithScrolling` helper to locate and tap each navigation link.
    - **macOS**: It uses the `clickButtonWithScrolling` helper to navigate via pointer interactions.
3. **Completion**: Navigation terminates once the folder's list view is displayed on screen.

### Platform Considerations

- **tvOS**: This method is **not supported** on tvOS. Navigation on tvOS requires precise integer indices to drive the Siri Remote's directional input (simulating "Down" presses). Without a `RawRepresentable` conformance with `Int` raw values, the required index information is unavailable. Calling this method in a tvOS context will trigger a `fatalError`.
- **Scrolling**: The method automatically handles off-screen navigation links by performing small swipes (iOS/watchOS) or scroll events (macOS) until the target button becomes hittable.

## Parameters

| Name | Type | Description |
| :--- | :--- | :--- |
| `app` | `XCUIApplication` | The running application instance to perform navigation on. |

## Example

The following example demonstrates a complete, reproducible HarnessKit hierarchy and how to navigate to a folder level that does not use `Int` raw values.

```swift
import XCTest
import SwiftUI
import HarnessKit
import HarnessKitTesting

// 1. Define the Project Root
enum MyProject: PathProject {
    static let name = "Component Showcase"
    static let folders: [any PathFolder.Type] = [ControlsFolder.self]
}

// 2. Define a Folder (no Int raw value)
enum ControlsFolder: PathFolder {
    typealias ParentSection = MyProject
    static let name = "Controls"
    
    case sliders
    case steppers
    
    var description: String {
        switch self {
        case .sliders: return "Sliders"
        case .steppers: return "Steppers"
        }
    }
    
    @ViewBuilder
    var view: some View {
        switch self {
        case .sliders: Text("Slider Preview")
        case .steppers: Text("Stepper Preview")
        }
    }
}

// 3. Navigate in a UI Test
final class ShowcaseUITests: XCTestCase {
    func testNavigateToControls() {
        let app = XCUIApplication()
        app.launch()
        
        // Use any case to navigate to the "Controls" folder list.
        // This will tap "Controls" in the root list.
        ControlsFolder.sliders.navigate(app: app)
        
        // Verification: We are now in the Controls list
        XCTAssertTrue(app.staticTexts["Sliders"].exists)
        XCTAssertTrue(app.staticTexts["Steppers"].exists)
    }
}
```

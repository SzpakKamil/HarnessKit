# ``HarnessKitTesting/clickButtonWithScrolling(app:titleOrIdentifier:maxScrolls:)``

Finds a button by label or accessibility identifier and clicks it, scrolling the window if needed.

@Metadata {
    @SupportedLanguage(swift)
    @Available(macOS, introduced: "11.0")
    @DocumentationExtension(mergeBehavior: override)
}

@Options {
    @AutomaticArticleSubheading(disabled)
}

## Overview

This macOS-specific helper method automates clicking buttons that may be off-screen. It employs a multi-stage search strategy and a deterministic scrolling loop to ensure reliability in UI tests.

### Search Strategy
The method first attempts to find the button using the exact string as an index in `app.buttons`. If the button is not immediately hittable or does not exist, it falls back to an `NSPredicate` query:
```swift
NSPredicate(format: "label == %@ OR identifier == %@", titleOrIdentifier, titleOrIdentifier)
```
This ensures that the target can be identified by either its human-readable label or its underlying `accessibilityIdentifier`.

### Scrolling Mechanism
If the target is not visible, the method initiates a loop (up to `maxScrolls` times):
1. **Scroll View Detection**: It checks for `app.scrollViews.firstMatch`.
2. **Deterministic Scroll**: If a scroll view exists, it performs `scrollView.scroll(byDeltaX: 0, deltaY: -2)`. On macOS, a negative `deltaY` scrolls content upward, revealing elements below.
3. **Keyboard Fallback**: If no scroll view is detected, it sends a `.pageDown` keystroke (`app.typeKey(.pageDown, modifierFlags: [])`) to trigger native list navigation.
4. **State Refresh**: Between each attempt, the method yields to the main run loop for 50ms (`RunLoop.current.run(until: ...)`) to allow XCTest to refresh the element tree.

## Parameters

| Name | Type | Description |
| :--- | :--- | :--- |
| `app` | `XCUIApplication` | The running application instance to interact with. |
| `titleOrIdentifier` | `String` | The label text or `accessibilityIdentifier` of the target button. |
| `maxScrolls` | `Int` | The maximum number of scroll iterations before failure (default is 20). |

## Example

The following example demonstrates a complete HarnessKit hierarchy (Project -> Folder -> Case) and how to use `clickButtonWithScrolling` in a macOS UI test.

```swift
import HarnessKit
import HarnessKitTesting
import XCTest
import SwiftUI

// 1. Define the Project (The Root)
enum DesignSystemProject: PathProject {
    static let name = "Design System"
    static let folders: [any PathFolder.Type] = [AlertsFolder.self]
}

// 2. Define the Folder
enum AlertsFolder: Int, PathFolder {
    typealias ParentSection = DesignSystemProject
    static let name = "Alerts"
    
    // 3. Define the Cases (The Leaves)
    case success
    case warning
    case error
    
    var description: String {
        switch self {
        case .success: return "Success Alert"
        case .warning: return "Warning Notification"
        case .error:   return "Critical Error"
        }
    }
    
    @ViewBuilder
    var view: some View {
        switch self {
        case .success: Text("Success View")
        case .warning: Text("Warning View")
        case .error:   Text("Error View")
        }
    }
}

// 4. UI Test Implementation
final class DesignSystemTests: XCTestCase {
    func testNavigateToCriticalError() {
        let app = XCUIApplication()
        app.launch()
        
        // Navigate through the hierarchy using the scrolling helper
        clickButtonWithScrolling(app: app, titleOrIdentifier: "Alerts")
        clickButtonWithScrolling(app: app, titleOrIdentifier: "Critical Error")
        
        // Verify destination
        XCTAssertTrue(app.staticTexts["Error View"].exists)
    }
}
```

## Topics

### Navigation Helpers

- <doc:HarnessKitTesting/tapButtonWithScrolling(app:titleOrIdentifier:maxSwipes:)>
- ``HarnessKit/PathFolder/navigate(app:)``

# About HarnessKit

@Metadata {
    @SupportedLanguage(swift)
    @TitleHeading("Getting Started")
    @Available(iOS, introduced: "14.0")
    @Available(iPadOS, introduced: "14.0")
    @Available(macOS, introduced: "11.0")
    @Available(tvOS, introduced: "14.0")
    @Available(watchOS, introduced: "10.0")
    @Available(visionOS, introduced: "1.0")
    @Available(swift, introduced: "5.9")
    @Available(Xcode, introduced: "15.0")
    @PageColor(blue)
    @DocumentationExtension(mergeBehavior: override)
}

@Options {
    @AutomaticSeeAlso(disabled)
}

A structured navigation harness for SwiftUI demo apps and component previews. 

## Overview

``HarnessKit`` is a lightweight, protocol-oriented framework designed to solve the "demo app boilerplate" problem. Instead of manually building navigation lists and detail views for every component in your design system, you define a structured tree of your views using ``PathProject`` and ``PathFolder``. ``HarnessKit`` then generates the entire navigation UI and provides automated testing hooks.

All members of HarnessKit must be accessed on the **main actor**.

## Building the Hierarchy

To use HarnessKit, you build a tree structure consisting of a single project root, one or more folders, and individual cases for each view.

### 1. Define the Project Root

The root of your harness is a type that conforms to ``PathProject``. This defines the top-level name and the initial set of folders.

```swift
import HarnessKit

enum MyDesignSystem: PathProject {
    static let name = "Design System"
    static let folders: [any PathFolder.Type] = [
        ComponentsFolder.self
    ]
}
```

### 2. Create Navigation Folders

Folders are enums conforming to ``PathFolder``. Each folder specifies its `ParentSection` (either the project or another folder) and a list of navigable `options` (its enum cases).

```swift
import HarnessKit
import SwiftUI

enum ComponentsFolder: Int, PathFolder {
    typealias ParentSection = MyDesignSystem
    static let name = "Components"
    
    case buttons
    case labels
    
    var description: String {
        switch self {
        case .buttons: return "Buttons"
        case .labels: return "Labels"
        }
    }
    
    static var folders: [any PathFolder.Type] {
        [ButtonsFolder.self]
    }
}
```

### 3. Define Leaf Views

A leaf folder contains the actual SwiftUI views you want to preview. Each enum case maps to a specific view via the `view` property.

```swift
import HarnessKit
import SwiftUI

enum ButtonsFolder: Int, PathFolder {
    typealias ParentSection = ComponentsFolder
    static let name = "Buttons"
    
    case primary
    case secondary
    
    var description: String {
        switch self {
        case .primary: return "Primary Button"
        case .secondary: return "Secondary Button"
        }
    }
    
    @ViewBuilder
    var view: some View {
        switch self {
        case .primary:
            Button("Primary") { }.buttonStyle(.borderedProminent)
        case .secondary:
            Button("Secondary") { }.buttonStyle(.bordered)
        }
    }
}
```

When a case needs to show multiple states of a component, wrap the `view` body in ``HarnessPreview``. It cycles through variants on tap, so no `@State` is needed in the folder:

```swift
@ViewBuilder
var view: some View {
    HarnessPreview { isOn in
        MyToggleComponent(isOn: isOn)
    }
}
```

## Rendering the Harness

The ``HarnessView`` is the entry point for your SwiftUI app. It takes your project type as a generic parameter and renders the entire navigation tree automatically.

```swift
import SwiftUI
import HarnessKit

@main
struct DesignSystemApp: App {
    var body: some Scene {
        WindowGroup {
            HarnessView<MyDesignSystem>()
        }
    }
}
```

## Automated UI Testing

HarnessKit provides a powerful testing module, `HarnessKitTesting`, which allows you to navigate to any screen in a UI test with a single line of code. This bypasses the need for fragile, manual navigation logic in your tests.

### Path-Based Navigation

For types conforming to `RawRepresentable` with `Int` raw values (like the enums above), you can navigate directly to a case.

```swift
import XCTest
import HarnessKitTesting

final class DesignSystemUITests: XCTestCase {
    func testPrimaryButton() {
        let app = XCUIApplication()
        app.launch()

        // Full hierarchy: Project -> ComponentsFolder -> ButtonsFolder -> .primary
        ButtonsFolder.primary.navigate(app: app)

        XCTAssertTrue(app.buttons["Primary"].exists)
    }
}
```

### Variant Testing

When a case uses ``HarnessPreview``, `HarnessKitTesting` provides `advancePreview(app:)` to step forward one variant and `iteratePreview(app:variantCount:action:)` to visit all variants in sequence:

```swift
func testAllButtonStyles() {
    let app = XCUIApplication()
    app.launch()

    ButtonsFolder.primary.iteratePreview(app: app, variantCount: 3) { index in
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Style \(index)"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
```

### Cross-Platform Support

- **iOS/macOS/watchOS**: Uses label-based matching and automatic scrolling to find and interact with navigation links.
- **tvOS**: Uses `XCUIRemote` to perform precise directional presses based on the integer path IDs, ensuring reliable navigation on a platform where label matching is often limited.

## Deep Linking and Resolution

Every node in the harness has a unique path identified by integers and strings. You can use the `PathResolver` (via extensions on ``PathFolder``) to retrieve these paths for debugging or custom deep-linking implementations.

- ``PathFolder/ids(for:)``: Returns the sequence of integer indices from the root to a specific case.
- ``PathFolder/namePath(for:)``: Returns a slash-separated string representation (e.g., `"Components/Buttons/primary"`).

## Why Use HarnessKit?

- **Efficiency**: Adding a new component preview is as simple as adding an enum case.
- **Consistency**: Provides a unified, searchable structure for all previews across your project.
- **Reliability**: Decouples UI tests from the underlying navigation implementation, making them more resilient to UI changes.

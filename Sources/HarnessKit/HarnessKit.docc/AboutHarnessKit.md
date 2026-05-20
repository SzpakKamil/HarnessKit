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

``HarnessKit`` is a protocol-oriented framework for the boilerplate that comes with every design system app. Instead of writing the same navigation list and detail screens for each new component, you describe your hierarchy as types. ``PathProject`` is the root, ``PathFolder`` is everything below it. ``HarnessView`` renders the whole tree, and `HarnessKitTesting` lets a UI test jump to any leaf in one call.

Every member of HarnessKit is isolated to the main actor.

## Building the Hierarchy

A harness has three parts: one project root, any number of folders, and a leaf view per folder case.

### 1. The Project Root

The root is a caseless enum conforming to ``PathProject``. It carries the navigation title and the list of top-level folders.

```swift
import HarnessKit

enum MyDesignSystem: PathProject {
    static let name = "Design System"
    static let folders: [any PathFolder.Type] = [
        ComponentsFolder.self
    ]
}
```

### 2. Navigation Folders

Folders are enums conforming to ``PathFolder``. Each one points at its parent through `ParentSection` and lists its own subfolders.

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

### 3. Leaf Views

A leaf folder maps each enum case to a SwiftUI view through the `view` property.

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

When a case wants to demo several states of a component, wrap the body in ``HarnessPreview``. It owns the variant index internally, so the folder stays a plain enum:

```swift
@ViewBuilder
var view: some View {
    HarnessPreview { isOn in
        MyToggleComponent(isOn: isOn)
    }
}
```

## Rendering the Harness

``HarnessView`` is the entry point. Pass your project type as the generic parameter.

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

`HarnessKitTesting` adds `navigate(app:)` to every folder case. The library handles the taps, clicks, scrolls, or remote presses your platform needs.

### Path-Based Navigation

For folders backed by `Int` raw values, navigate straight to a case from a test.

```swift
import XCTest
import HarnessKitTesting

final class DesignSystemUITests: XCTestCase {
    func testPrimaryButton() {
        let app = XCUIApplication()
        app.launch()

        // Walks MyDesignSystem -> ComponentsFolder -> ButtonsFolder -> .primary
        ButtonsFolder.primary.navigate(app: app)

        XCTAssertTrue(app.buttons["Primary"].exists)
    }
}
```

### Variant Testing

For cases backed by ``HarnessPreview``, call `advancePreview(app:)` to step one variant or `iteratePreview(app:variantCount:action:)` to visit every variant in order:

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

On iOS, iPadOS, macOS, and watchOS, the library matches buttons by label and scrolls until they are hittable. On tvOS, it sends `XCUIRemote` directional presses calculated from each folder's integer path id.

## Deep Linking and Resolution

Every node carries a unique path of integers and strings. Use the static resolver methods on ``PathFolder`` to read them.

- ``PathFolder/ids(for:)`` returns the integer path to a specific case.
- ``PathFolder/namePath(for:)`` returns a slash-joined string like `"Components/Buttons/primary"`.

## Why Use HarnessKit?

- Adding a preview is one new enum case.
- Every preview lives in the same searchable tree.
- UI tests stop breaking when you rearrange screens.

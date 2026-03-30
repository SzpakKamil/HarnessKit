# Usage

@Metadata {
    @SupportedLanguage(swift)
    @TitleHeading("Functionality")
    @Available(iOS, introduced: "14.0")
    @Available(iPadOS, introduced: "14.0")
    @Available(macOS, introduced: "11.0")
    @Available(tvOS, introduced: "14.0")
    @Available(watchOS, introduced: "10.0")
    @Available(visionOS, introduced: "1.0")
    @Available(swift, introduced: "5.9")
    @Available(Xcode, introduced: "15.0")
    @PageColor(blue)
}

@Options {
    @AutomaticSeeAlso(disabled)
}

Build a navigation tree, render it, resolve paths, and automate UI testing.

## Overview

`HarnessKit` exposes three main operations: constructing a hierarchy, rendering it with ``HarnessView``, and resolving paths via ``PathFolder`` static methods. Add `HarnessKitTesting` to a UI test target to navigate to any node in one call.

## Building the Hierarchy

### Define the Project Root

Conform a caseless enum to ``PathProject``. Set `name` to the navigation title and `folders` to the ordered list of top-level folder types.

```swift
import HarnessKit

@MainActor
enum MyDemoProject: PathProject {
    static let name = "Design System"
    static let folders: [any PathFolder.Type] = [ButtonsFolder.self]
}
```

### Define Folders

Conform an enum to ``PathFolder`` and set `ParentSection` to link it to its parent. Use `Int` raw values for full platform coverage including tvOS remote navigation.

```swift
import SwiftUI
import HarnessKit

@MainActor
enum ButtonsFolder: Int, PathFolder {
    typealias ParentSection = MyDemoProject
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
        case .primary: Button("Primary") {}.buttonStyle(.borderedProminent)
        case .secondary: Button("Secondary") {}.buttonStyle(.bordered)
        }
    }
}
```

Nest folders by setting `ParentSection` to another `PathFolder` type and populating `folders`:

```swift
@MainActor
enum ComponentsFolder: Int, PathFolder {
    typealias ParentSection = MyDemoProject
    static let name = "Components"
    static let folders: [any PathFolder.Type] = [ButtonsFolder.self]

    case labels

    var description: String { "Labels" }
    var view: some View { Text("Labels Preview") }
}
```

## Rendering

Pass your ``PathProject`` type to ``HarnessView`` in the app entry point:

```swift
import SwiftUI
import HarnessKit

@main
struct DemoApp: App {
    var body: some Scene {
        WindowGroup {
            HarnessView<MyDemoProject>()
        }
    }
}
```

``HarnessView`` builds a `NavigationStack` on iOS 16+, macOS 13+, and tvOS 16+, and falls back to `NavigationView` on earlier platforms. The root list shows each folder by name. Selecting a folder drills into its sub-folders and cases. Selecting a case presents the associated view.

## Path Resolution

Every node carries a path built from its position in the hierarchy. Use the static ``PathFolder`` resolver methods to read these paths for debugging, deep linking, or accessibility identifiers.

- ``PathFolder/ids(for:)`` — integer path to a specific case, e.g. `[0, 1]`
- ``PathFolder/names(for:)`` — display-name components, e.g. `["Buttons", "secondary"]`
- ``PathFolder/namePath(for:)`` — slash-joined string, e.g. `"Buttons/secondary"`

```swift
import HarnessKit

// Integer path: [0, 0]
let ids = ButtonsFolder.ids(for: .primary)

// Name components: ["Buttons", "primary"]
let names = ButtonsFolder.names(for: .primary)

// Slash path: "Buttons/primary"
let path = ButtonsFolder.namePath(for: .primary)
```

Assign `namePath` as an `accessibilityIdentifier` on destination views to give UI tests a stable handle that does not depend on display text.

## Automated UI Testing

Import `HarnessKitTesting` in your UI test target and call `navigate(app:)` on any folder case. The library taps, scrolls, clicks, or sends remote presses depending on the platform.

```swift
import XCTest
import HarnessKitTesting

final class ButtonTests: XCTestCase {
    func testPrimaryButton() {
        let app = XCUIApplication()
        app.launch()

        ButtonsFolder.primary.navigate(app: app)

        XCTAssertTrue(app.buttons["Primary"].exists)
    }
}
```

## Next Steps

- <doc:HarnessKit>

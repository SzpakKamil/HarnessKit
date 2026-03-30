# About HarnessKitTesting

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
}

@Options {
    @AutomaticSeeAlso(disabled)
}

Automate UI navigation in XCUITest suites using your existing `HarnessKit` hierarchy.

## Overview

`HarnessKitTesting` reads the path metadata baked into your `PathProject` and `PathFolder` types and drives the app to any screen with a single call. You write `ButtonsFolder.primary.navigate(app: app)` and the library handles every tap, scroll, click, or remote press.

Each platform uses a different interaction model:

- **iOS and watchOS**: Scrolls lists upward in short press-then-drag steps until the target label is hittable, then taps it.
- **macOS**: Clicks buttons by label, scrolling the first scroll view or sending Page Down keystrokes when needed.
- **tvOS**: Activates the app, then sends `XCUIRemote` down presses calculated from each folder's index in its parent, followed by a select press. An additional `sleep(1)` after each level lets the navigation animation complete.

## Hierarchy Requirements

`navigate(app:)` reads `nameComponents` to get the ordered list of button labels to tap. For folders without `Int` raw values, it uses the type-level name path. For `Int`-raw-value enums (recommended), it also supports tvOS by reading `pathIds` and `rawValue` to count remote presses.

```swift
import HarnessKit
import SwiftUI

@MainActor
enum ButtonsFolder: Int, PathFolder {
    typealias ParentSection = MyProject
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

## Writing a UI Test

Launch the app and call `navigate(app:)` on the case you want to reach. Assert against what the destination renders.

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

## Stable Identifiers

`PathFolder.namePath(for:)` returns a slash-joined path string like `"Buttons/primary"`. Assign it as an `accessibilityIdentifier` on destination views and assert against it to avoid coupling tests to display text.

```swift
let path = ButtonsFolder.namePath(for: .primary)
XCTAssertTrue(app.staticTexts[path].exists)
```

## Next Steps

- <doc:SetUpTesting>
- <doc:HarnessKitTesting>

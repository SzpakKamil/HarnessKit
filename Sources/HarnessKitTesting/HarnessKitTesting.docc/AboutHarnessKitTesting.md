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

## Variant Preview Testing

When a folder case uses `HarnessPreview` in its `view`, `HarnessKitTesting` provides two methods to drive it from a test.

`advancePreview(app:)` steps forward by one variant. `advancePreview(app:steps:)` steps forward by a given count. Both wrap around automatically.

`iteratePreview(app:variantCount:action:)` navigates to the case and then calls a closure once per variant, advancing between each call:

```swift
ButtonsFolder.toggle.iteratePreview(app: app, variantCount: 2) { index in
    let attachment = XCTAttachment(screenshot: app.screenshot())
    attachment.name = "Variant \(index)"
    attachment.lifetime = .keepAlways
    add(attachment)
}
```

When you already have the variants array, the typed overloads are safer and more expressive. `iteratePreview(app:variants:action:)` passes the variant value directly; `iteratePreview(app:variants:indexedAction:)` also includes the zero-based index:

```swift
let styles: [CardStyle] = [.compact, .regular, .expanded]

// Value only
ButtonsFolder.card.iteratePreview(app: app, variants: styles) { style in
    XCTAssertTrue(app.staticTexts[style.title].exists)
}

// Value + index
ButtonsFolder.card.iteratePreview(app: app, variants: styles) { index, style in
    let attachment = XCTAttachment(screenshot: app.screenshot())
    attachment.name = "\(index): \(style)"
    attachment.lifetime = .keepAlways
    add(attachment)
}
```

On tvOS, each advance sends a Play/Pause remote press followed by a one-second sleep. On all other platforms it taps the element identified by the `"HarnessPreview"` accessibility identifier.

## Stable Identifiers

`PathFolder.namePath(for:)` returns a slash-joined path string like `"Buttons/primary"`. Assign it as an `accessibilityIdentifier` on destination views and assert against it to avoid coupling tests to display text.

```swift
let path = ButtonsFolder.namePath(for: .primary)
XCTAssertTrue(app.staticTexts[path].exists)
```

## Next Steps

- <doc:SetUpTesting>
- <doc:HarnessKitTesting>

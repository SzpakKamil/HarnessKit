# Set Up

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

Integrate `HarnessKit` into your SwiftUI project.

## Overview

`HarnessKit` ships as two products in a single Swift package: the core framework and a testing companion. Add them via Swift Package Manager and assign each to the correct target.

## Adding HarnessKit

1. In Xcode, select **File > Add Packages...**.
2. Enter the URL: `https://github.com/SzpakKamil/HarnessKit.git`.
3. Select a version (`1.0.0` or later) and click **Add Package**.
4. Assign `HarnessKit` to your main app target and `HarnessKitTesting` to your UI test target.

```swift
import HarnessKit
```

## Defining the Hierarchy

A harness tree has two components: a project root and one or more folders.

**Project root** — a caseless enum conforming to ``PathProject``:

```swift
import HarnessKit

@MainActor
enum MyProject: PathProject {
    static let name = "Design System"
    static let folders: [any PathFolder.Type] = [ButtonsFolder.self]
}
```

**Folder** — an enum conforming to ``PathFolder``. Use `Int` raw values to unlock tvOS remote navigation:

```swift
import SwiftUI
import HarnessKit

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

## Launching the Harness

Pass your ``PathProject`` type to ``HarnessView`` in the app entry point:

```swift
import SwiftUI
import HarnessKit

@main
struct HarnessApp: App {
    var body: some Scene {
        WindowGroup {
            HarnessView<MyProject>()
        }
    }
}
```

``HarnessView`` uses `NavigationStack` on iOS 16+, macOS 13+, and tvOS 16+, and falls back to `NavigationView` on earlier platforms.

## Variant Cycling

Wrap a folder's `view` in ``HarnessPreview`` to cycle through multiple component states without writing `@State` boilerplate. Tap (or press the appropriate key or remote button) to advance to the next variant:

```swift
@ViewBuilder
var view: some View {
    HarnessPreview { isOn in
        MyToggleComponent(isOn: isOn)
    }
}
```

Pass an explicit array for three or more states:

```swift
@ViewBuilder
var view: some View {
    HarnessPreview([Style.compact, .regular, .expanded]) { style in
        MyComponent(style: style)
    }
}
```

## Automated UI Testing

Import `HarnessKitTesting` in your UI test target and call `navigate(app:)` on any folder case:

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

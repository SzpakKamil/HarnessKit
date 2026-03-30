# Set Up Testing

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

Add `HarnessKitTesting` to your UI test target and automate navigation across every Apple platform.

## Overview

`HarnessKitTesting` is a companion product in the HarnessKit package. Link it to your XCUITest target to unlock the `navigate(app:)` method on all `PathFolder` cases.

## Adding HarnessKitTesting

1. In Xcode, select **File > Add Packages...**.
2. Enter `https://github.com/SzpakKamil/HarnessKit.git` and click **Add Package**.
3. In the package product list, assign `HarnessKit` to your main app target and `HarnessKitTesting` to your **UI test target**.

> Important: Do not add `HarnessKitTesting` to the main app target. It imports `XCTest`, which cannot link into a production binary.

Import the module at the top of each test file:

```swift
import XCTest
import HarnessKitTesting
```

## Defining the Hierarchy

`navigate(app:)` reads path metadata from your `PathProject` and `PathFolder` types at runtime. Both the app and the test target must reference the same hierarchy types.

Define the root:

```swift
import HarnessKit

@MainActor
enum MyProject: PathProject {
    static let name = "Design System"
    static let folders: [any PathFolder.Type] = [ButtonsFolder.self]
}
```

Define a leaf folder. Use `Int` raw values for tvOS support:

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

## Running a Test

Launch the app and call `navigate(app:)` on the case you want to reach:

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

## Testing Variant Previews

When a folder case's `view` uses `HarnessPreview`, use `advancePreview(app:)` to step forward one variant after navigating, or `iteratePreview(app:variantCount:action:)` to visit all variants in sequence:

```swift
func testToggleVariants() {
    let app = XCUIApplication()
    app.launch()

    ButtonsFolder.primary.iteratePreview(app: app, variantCount: 2) { index in
        // index 0 = false, index 1 = true
        XCTAssertTrue(app.otherElements["HarnessPreview"].exists)
    }
}
```

`variantCount` must match the number of elements in the array passed to `HarnessPreview`. The `iteratePreview` call handles navigation and advancement automatically.

## Troubleshooting

- **Linking error**: Confirm `HarnessKitTesting` is linked to the UI test target, not the app target.
- **Button not found on tvOS**: Folders must use `Int` raw values. Without them, tvOS navigation throws a `fatalError` at runtime.
- **Name collision**: Use the full module path: `MyModule.ButtonsFolder.primary.navigate(app: app)`.
- **Deployment target mismatch**: All targets must meet the minimum platform requirements (iOS 14.0+, macOS 11.0+, tvOS 14.0+, watchOS 10.0+).

## Next Steps

- <doc:HarnessKitTesting>

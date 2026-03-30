# HarnessKit
![Swift Version](https://img.shields.io/badge/Swift-5.9%2B-teal.svg)
![Platforms](https://img.shields.io/badge/Platforms-iOS%2014.0+%20|%20iPadOS%2014.0+%20|%20macOS%2011.0+%20|%20watchOS%2010.0+%20|%20tvOS%2014.0+%20|%20visionOS%201.0+-15437D.svg)
![License](https://img.shields.io/badge/License-MIT-C8ECFE.svg)

A structured navigation harness for SwiftUI demo apps and component previews. Define a tree of views using `PathProject` and `PathFolder`, render it with `HarnessView`, then navigate to any screen in UI tests with a single call.

Visit the [Documentation](https://documentation.kamilszpak.com/documentation/harnesskit).

---

## Table of Contents

* [Overview](#overview)
* [Implementation](#implementation)
* [UI Testing](#ui-testing)
* [Resources](#resources)
* [Installation](#installation)
* [Requirements](#requirements)
* [License](#license)

## Overview

* Define a `PathProject` as the root of your view hierarchy.
* Organize views into `PathFolder` sections and subsections.
* Render the entire tree with `HarnessView<YourProject>`.
* Navigate to any view in UI tests via `someCase.navigate(app:)`.

## Implementation

HarnessKit uses two protocols: `PathProject` for the root and `PathFolder` for each section.

### Define a Project

```swift
import HarnessKit

struct MyProject: PathProject {
    static let name = "My App"
    static let folders: [any PathFolder.Type] = [ButtonsFolder.self, TextFolder.self]
}
```

### Define Folders

```swift
import SwiftUI
import HarnessKit

enum ButtonsFolder: PathFolder {
    typealias ParentSection = MyProject
    static let name = "Buttons"
    static let folders: [any PathFolder.Type] = []

    case primary
    case secondary
    case destructive

    var description: String {
        switch self {
        case .primary:     "Primary Button"
        case .secondary:   "Secondary Button"
        case .destructive: "Destructive Button"
        }
    }

    @ViewBuilder
    var view: some View {
        switch self {
        case .primary:     PrimaryButtonPreview()
        case .secondary:   SecondaryButtonPreview()
        case .destructive: DestructiveButtonPreview()
        }
    }
}
```

### Render the Harness

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

`HarnessView` builds a `NavigationStack` from your project tree. Tap any folder to drill down; tap any option to open the associated view.

## UI Testing

Add `HarnessKitTesting` to your UI test target, then call `navigate(app:)` on any folder case.

```swift
import XCTest
import HarnessKitTesting

class ButtonTests: XCTestCase {
    func testDestructiveButtonAppears() {
        let app = XCUIApplication()
        app.launch()

        ButtonsFolder.destructive.navigate(app: app)

        XCTAssertTrue(app.buttons["Delete"].exists)
    }
}
```

`navigate(app:)` resolves the full path from the project root and taps each level in sequence. On tvOS it uses `XCUIRemote` directional presses instead of tap gestures.

## Resources

* **Documentation**: [API Reference](https://documentation.kamilszpak.com/documentation/harnesskit)
* **GitHub**: [SzpakKamil/HarnessKit](https://github.com/SzpakKamil/HarnessKit) — Track issues and contributions.
* **Index**: [Swift Package Index](https://swiftpackageindex.com/SzpakKamil/HarnessKit) — View compatibility and release history.

## Installation

### Swift Package Manager

Add HarnessKit as a package dependency in your `Package.swift` file.

```swift
dependencies: [
    .package(url: "https://github.com/SzpakKamil/HarnessKit.git", from: "1.0.0")
]
```

Add `HarnessKit` to your harness app target and `HarnessKitTesting` to your UI test target:

```swift
targets: [
    .target(
        name: "MyHarnessApp",
        dependencies: ["HarnessKit"]
    ),
    .testTarget(
        name: "MyHarnessAppUITests",
        dependencies: ["HarnessKitTesting"]
    )
]
```

## Requirements

* **Platforms**: iOS 14.0+, macOS 11.0+, tvOS 14.0+, watchOS 10.0+, visionOS 1.0+
* **Tools**: Swift 5.9+, Xcode 15.0+

## License

HarnessKit is released under the MIT license.

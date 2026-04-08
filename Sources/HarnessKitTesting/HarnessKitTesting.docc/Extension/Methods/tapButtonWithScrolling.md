# ``HarnessKitTesting/tapButtonWithScrolling(app:titleOrIdentifier:maxSwipes:)``

Finds a button by label or accessibility identifier and taps it, scrolling the list if needed.

@Metadata {
    @SupportedLanguage(swift)
    @Available(iOS, introduced: "14.0")
    @Available(iPadOS, introduced: "14.0")
    @Available(watchOS, introduced: "10.0")
    @DocumentationExtension(mergeBehavior: override)
}

@Options {
    @AutomaticArticleSubheading(disabled)
}

## Overview

This iOS/watchOS helper method automates tapping buttons that may be off-screen in a scrollable list. It employs a multi-stage search strategy and a deterministic scrolling loop to ensure reliability in UI tests.

### Search Strategy

The method first attempts to find the button using the exact string as an index in `app.buttons`. If the button is not immediately hittable or does not exist, it falls back to an `NSPredicate` query:

```swift
NSPredicate(format: "label == %@ OR identifier == %@", titleOrIdentifier, titleOrIdentifier)
```

This ensures that the target can be identified by either its human-readable label or its underlying `accessibilityIdentifier`.

### Scrolling Mechanism

If the target is not visible, the method initiates a loop (up to `maxSwipes` times):

1. **Scroll Target Detection**: It checks for `app.tables.firstMatch`, then `app.collectionViews.firstMatch`, then `app.scrollViews.firstMatch`.
2. **Small Swipe**: Performs a short upward swipe (0.18 height fraction) using ``smallSwipeUp(on:distanceRatio:hold:)`` to avoid overshooting.
3. **State Refresh**: Between each attempt, the method yields to the main run loop for 50ms to allow XCTest to refresh the element tree.

### Post-Scroll Recovery

After the loop, if the button exists but is not yet hittable (partially visible), the method performs a small reverse nudge (scroll down slightly) followed by another small upward swipe to bring the button into the hittable zone. If the button still cannot be tapped, the test fails with `XCTFail`.

## Parameters

| Name | Type | Description |
| :--- | :--- | :--- |
| `app` | `XCUIApplication` | The running application instance to interact with. |
| `titleOrIdentifier` | `String` | The label text or `accessibilityIdentifier` of the target button. |
| `maxSwipes` | `Int` | The maximum number of scroll attempts before failure (default is 40). |

## Example

```swift
import XCTest
import HarnessKitTesting

final class NavigationTests: XCTestCase {
    func testNavigateToDeepItem() {
        let app = XCUIApplication()
        app.launch()

        // Tap through the hierarchy, scrolling as needed
        tapButtonWithScrolling(app: app, titleOrIdentifier: "Components")
        tapButtonWithScrolling(app: app, titleOrIdentifier: "Buttons")
        tapButtonWithScrolling(app: app, titleOrIdentifier: "Primary Button")

        XCTAssertTrue(app.buttons["Primary"].exists)
    }
}
```

## Topics

### Navigation Helpers

- <doc:HarnessKitTesting/clickButtonWithScrolling(app:titleOrIdentifier:maxScrolls:)>
- ``HarnessKit/PathFolder/navigate(app:)``

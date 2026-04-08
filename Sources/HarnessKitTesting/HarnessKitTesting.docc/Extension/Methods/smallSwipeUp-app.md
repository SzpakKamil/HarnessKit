# ``HarnessKitTesting/smallSwipeUp(on:distanceRatio:hold:)``

Performs a short upward swipe on a scrollable element.

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

This low-level helper performs a short press-then-drag gesture on a given `XCUIElement`, simulating a small upward scroll. It is used internally by ``tapButtonWithScrolling(app:titleOrIdentifier:maxSwipes:)`` to reveal off-screen buttons one step at a time.

### Platform Behaviour

| Platform | Mechanism |
| :--- | :--- |
| iOS / iPadOS | Anchors the swipe start at 70% from the top of the element, then drags upward by `distanceRatio` of the element height. |
| watchOS | Rotates the Digital Crown (`XCUIDevice.shared.rotateDigitalCrown`) instead of swiping, followed by a 1-second sleep. |

### Swipe Geometry

The swipe originates at the center-bottom area of the element (normalized offset `dx: 0.5, dy: 0.7`). The `distanceRatio` controls how far upward the drag travels, clamped between `0.02` and `0.9` to prevent zero-length or full-screen drags.

The short `hold` duration (default 0.01 seconds) prevents XCTest from interpreting the gesture as a long press.

## Parameters

| Name | Type | Description |
| :--- | :--- | :--- |
| `element` | `XCUIElement` | The scrollable element to swipe on (typically a table, collection view, or scroll view). |
| `distanceRatio` | `CGFloat` | Swipe distance as a fraction of the element height. Default `0.2` (20%). Clamped to `0.02...0.9`. |
| `hold` | `TimeInterval` | Press duration before the drag begins. Default `0.01` seconds. |

## Example

```swift
import XCTest
import HarnessKitTesting

// Scroll a table down by 30% of its height
let table = app.tables.firstMatch
smallSwipeUp(on: table, distanceRatio: 0.3)
```

## Topics

### Navigation Helpers

- <doc:HarnessKitTesting/tapButtonWithScrolling(app:titleOrIdentifier:maxSwipes:)>
- <doc:HarnessKitTesting/clickButtonWithScrolling(app:titleOrIdentifier:maxScrolls:)>

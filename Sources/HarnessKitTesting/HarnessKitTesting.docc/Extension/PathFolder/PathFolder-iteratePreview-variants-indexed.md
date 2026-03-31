# ``HarnessKit/PathFolder/iteratePreview(app:variants:indexedAction:)``

Navigates to this folder case, then visits each typed variant in sequence, passing both the index and the value to the action.

@Metadata {
    @SupportedLanguage(swift)
    @Available(iOS, introduced: "14.0")
    @Available(iPadOS, introduced: "14.0")
    @Available(macOS, introduced: "11.0")
    @Available(tvOS, introduced: "14.0")
    @Available(watchOS, introduced: "10.0")
    @Available(visionOS, introduced: "1.0")
    @Available(swift, introduced: "5.9")
    @Available(Xcode, introduced: "15.0")
    @DocumentationExtension(mergeBehavior: override)
}

@Options {
    @AutomaticArticleSubheading(disabled)
}

## Overview

This overload accepts the same array you pass to `HarnessKit/HarnessPreview`, so the count is always consistent and the closure receives the typed variant value alongside its zero-based index.

After navigating, the method calls `indexedAction` with `(0, variants[0])` for the first variant, advances once, calls `(1, variants[1])`, and so on. The last variant does not advance further.

### Typed Screenshot Loop

```swift
let styles: [CardStyle] = [.compact, .regular, .expanded]

ButtonsFolder.card.iteratePreview(app: app, variants: styles) { index, style in
    let attachment = XCTAttachment(screenshot: app.screenshot())
    attachment.name = "Style \(style)"
    attachment.lifetime = .keepAlways
    add(attachment)
}
```

### Typed Assertion Per Variant

```swift
let labels: [String] = ["Compact", "Regular", "Expanded"]

ButtonsFolder.card.iteratePreview(app: app, variants: labels) { index, label in
    XCTAssertTrue(app.staticTexts[label].exists, "Expected label '\(label)' at index \(index)")
}
```

> Note: This method is isolated to the `@MainActor`. It is safe to call directly from `XCTestCase` methods in modern Swift.

## Parameters

| Name | Type | Description |
| :--- | :--- | :--- |
| `app` | `XCUIApplication` | The running application instance under test. |
| `variants` | `[V]` | The ordered list of variant values. Must match what was passed to `HarnessKit/HarnessPreview`. The count is derived automatically. |
| `indexedAction` | `(Int, V) -> Void` | A closure called once per variant, receiving the zero-based index and the typed variant value. |

## See Also

- ``iteratePreview(app:variantCount:action:)``
- ``iteratePreview(app:variants:action:)``
- ``advancePreview(app:)``
- ``advancePreview(app:steps:)``

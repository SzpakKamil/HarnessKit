# ``HarnessKit/PathFolder/iteratePreview(app:variants:action:)``

Navigates to this folder case, then visits each typed variant in sequence, passing the value directly to the action.

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

This overload accepts the same array you pass to `HarnessKit/HarnessPreview`, so the count is always consistent. The closure receives each typed variant value in order — use this when the index is not needed.

After navigating, the method calls `action` with `variants[0]` for the first variant, advances once, calls `action` with `variants[1]`, and so on. The last variant does not advance further.

### Assertion Per Variant

```swift
ButtonsFolder.toggle.iteratePreview(app: app, variants: [false, true]) { isOn in
    let label = isOn ? "On" : "Off"
    XCTAssertTrue(app.staticTexts[label].exists)
}
```

### Screenshot Per Variant

```swift
ButtonsFolder.card.iteratePreview(app: app, variants: CardStyle.allCases) { style in
    let attachment = XCTAttachment(screenshot: app.screenshot())
    attachment.name = "\(style)"
    attachment.lifetime = .keepAlways
    add(attachment)
}
```

> Note: This method is isolated to the `@MainActor`. It is safe to call directly from `XCTestCase` methods in modern Swift.

## Parameters

| Name | Type | Description |
| :--- | :--- | :--- |
| `app` | `XCUIApplication` | The running application instance under test. |
| `variants` | `[V]` | The ordered list of variant values. Must match what was passed to `HarnessKit/HarnessPreview`. The count is derived automatically. |
| `action` | `(V) -> Void` | A closure called once per variant, receiving the typed variant value. |

## See Also

- ``iteratePreview(app:variantCount:action:)``
- ``iteratePreview(app:variants:indexedAction:)``
- ``advancePreview(app:)``
- ``advancePreview(app:steps:)``

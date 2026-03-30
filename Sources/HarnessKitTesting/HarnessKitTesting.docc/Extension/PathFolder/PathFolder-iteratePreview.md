# ``HarnessKit/PathFolder/iteratePreview(app:variantCount:action:)``

Navigates to this folder case, then visits each variant in sequence.

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

After navigating, the method calls `action` with index `0` for the first variant, advances once, calls `action` with index `1`, and so on. The last variant does not advance further, so the total number of `action` calls equals `variantCount`.

`variantCount` must match the number of elements in the array passed to `HarnessKit/HarnessPreview`. Passing a smaller count stops early; passing a larger count wraps the preview back to earlier variants.

### Automated Screenshot Loop

```swift
ButtonsFolder.primary.iteratePreview(app: app, variantCount: 3) { index in
    let attachment = XCTAttachment(screenshot: app.screenshot())
    attachment.name = "Variant \(index)"
    attachment.lifetime = .keepAlways
    add(attachment)
}
```

### Assertion Per Variant

```swift
let expectedLabels = ["Off", "On"]
ButtonsFolder.toggle.iteratePreview(app: app, variantCount: 2) { index in
    XCTAssertTrue(app.staticTexts[expectedLabels[index]].exists)
}
```

> Note: This method is isolated to the `@MainActor`. It is safe to call directly from `XCTestCase` methods in modern Swift.

## Parameters

| Name | Type | Description |
| :--- | :--- | :--- |
| `app` | `XCUIApplication` | The running application instance under test. |
| `variantCount` | `Int` | The total number of variants to visit. Should match the array length passed to `HarnessKit/HarnessPreview`. |
| `action` | `(Int) -> Void` | A closure called once per variant, receiving the zero-based variant index. |

## See Also

- ``advancePreview(app:)``
- ``advancePreview(app:steps:)``

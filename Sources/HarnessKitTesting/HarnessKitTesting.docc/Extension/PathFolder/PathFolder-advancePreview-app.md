# ``HarnessKit/PathFolder/advancePreview(app:)``

Advances the on-screen `HarnessKit/HarnessPreview` by one variant.

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

Equivalent to calling ``advancePreview(app:steps:)`` with `steps: 1`. Use this when you need to move forward by exactly one variant after navigating to a folder case.

```swift
ButtonsFolder.primary.navigate(app: app)
ButtonsFolder.primary.advancePreview(app: app)
XCTAssertTrue(app.staticTexts["Variant 2 Label"].exists)
```

On tvOS this sends a Play/Pause remote press followed by a one-second sleep to allow the animation to complete. On all other platforms it taps the element identified by `"HarnessPreview"`.

> Note: This method is isolated to the `@MainActor`. It is safe to call directly from `XCTestCase` methods in modern Swift.

## Parameters

| Name | Type | Description |
| :--- | :--- | :--- |
| `app` | `XCUIApplication` | The running application instance under test. |

## See Also

- ``advancePreview(app:steps:)``
- ``iteratePreview(app:variantCount:action:)``

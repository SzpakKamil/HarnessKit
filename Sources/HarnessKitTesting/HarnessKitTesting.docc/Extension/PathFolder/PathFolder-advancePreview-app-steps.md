# ``HarnessKit/PathFolder/advancePreview(app:steps:)``

Advances the on-screen `HarnessKit/HarnessPreview` by the given number of steps.

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

Each step triggers one interaction — a tap on iOS/macOS/watchOS/visionOS, a Play/Pause remote press on tvOS — advancing the `HarnessKit/HarnessPreview` to the next variant. Steps wrap around automatically once the last variant is reached.

Passing `0` is a no-op. Passing a count equal to the number of variants returns the preview to its initial state.

```swift
// Navigate to a case, then jump two variants ahead.
ButtonsFolder.primary.navigate(app: app)
ButtonsFolder.primary.advancePreview(app: app, steps: 2)
XCTAssertTrue(app.staticTexts["Variant 3 Label"].exists)
```

### Platform Behaviour

| Platform | Interaction per Step |
| :--- | :--- |
| iOS, watchOS, visionOS | Tap `otherElements["HarnessPreview"]` |
| macOS | Click `otherElements["HarnessPreview"]` (tap, scroll down, or down-arrow all advance in the app) |
| tvOS | `XCUIRemote.shared.press(.playPause)` + `sleep(1)` |

> Note: This method is isolated to the `@MainActor`. It is safe to call directly from `XCTestCase` methods in modern Swift.

## Parameters

| Name | Type | Description |
| :--- | :--- | :--- |
| `app` | `XCUIApplication` | The running application instance under test. |
| `steps` | `Int` | The number of variants to advance. Wraps automatically. Passing `0` does nothing. |

## See Also

- ``advancePreview(app:)``
- ``iteratePreview(app:variantCount:action:)``

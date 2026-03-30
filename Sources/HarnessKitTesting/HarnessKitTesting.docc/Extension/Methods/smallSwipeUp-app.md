# ``HarnessKitTesting/smallSwipeUp(on:distanceRatio:hold:)``

Performs a short upward swipe on the best available scrollable element in the app.

@Metadata {
    @SupportedLanguage(swift)
    @Available(iOS, introduced: "14.0")
    @Available(iPadOS, introduced: "14.0")
    @Available(watchOS, introduced: "10.0")
    @DocumentationExtension(mergeBehavior: override)
}

Selects the scroll target using a priority chain:
1. `app.tables.firstMatch`
2. `app.collectionViews.firstMatch`
3. `app.scrollViews.firstMatch`
4. `app.windows.firstMatch` (fallback)

- Parameter app: The `XCUIApplication` to scroll.
- Parameter distanceRatio: Swipe distance fraction. Default 0.2.
- Parameter hold: Press duration before drag. Default 0.01 s.

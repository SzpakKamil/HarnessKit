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

- Parameter element: The element to find
- Parameter distanceRatio: Swipe distance fraction. Default 0.2.
- Parameter hold: Press duration before drag. Default 0.01 s.

### Details

- **watchOS**: Rotates the Digital Crown instead of swiping.
- **iOS**: Anchors the swipe start at the center-bottom area (70% from top) and drags upward.

# ``HarnessKitTesting/smallSwipeUp(on:distanceRatio:hold:)``

Performs a short upward swipe on a specific UI element to scroll a list.

@Metadata {
    @SupportedLanguage(swift)
    @Available(iOS, introduced: "14.0")
    @Available(iPadOS, introduced: "14.0")
    @Available(watchOS, introduced: "10.0")
    @DocumentationExtension(mergeBehavior: override)
}

- Parameter element: The `XCUIElement` to swipe (typically a table or scroll view).
- Parameter distanceRatio: Fraction of the element's height to swipe. Clamped to `[0.02, 0.9]`. Default 0.2 (20%).
- Parameter hold: Press duration before beginning the drag. Default 0.01 s.

### Details

- **watchOS**: Rotates the Digital Crown instead of swiping.
- **iOS**: Anchors the swipe start at the center-bottom area (70% from top) and drags upward.

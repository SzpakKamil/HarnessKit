# ``HarnessKitTesting/tapButtonWithScrolling(app:titleOrIdentifier:maxSwipes:)``

Finds a button by label or accessibility identifier and taps it, scrolling the list if needed.

@Metadata {
    @SupportedLanguage(swift)
    @Available(iOS, introduced: "14.0")
    @Available(iPadOS, introduced: "14.0")
    @Available(watchOS, introduced: "10.0")
    @DocumentationExtension(mergeBehavior: override)
}

- Parameter app: The `XCUIApplication` to interact with.
- Parameter titleOrIdentifier: The button's label text or `accessibilityIdentifier`.
- Parameter maxSwipes: Maximum number of scroll attempts before failing. Default 40.

### Details

Falls back to a predicate query if the initial button check fails, matching either the human-readable label or the `accessibilityIdentifier`. Uses a scroll loop with a small step (0.18 height per swipe) to avoid overshooting.

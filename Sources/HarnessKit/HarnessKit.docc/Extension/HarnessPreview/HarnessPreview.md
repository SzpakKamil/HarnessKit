# ``HarnessKit/HarnessPreview``

A SwiftUI view that cycles through an ordered list of variants on user interaction.

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
    @AutomaticTitleHeading(enabled)
    @AutomaticSeeAlso(disabled)
    @AutomaticArticleSubheading(disabled)
}

## Overview

Use `HarnessPreview` inside a ``PathFolder`` `view` implementation when you need to show multiple states of a component. It owns the cycle state internally — no `@State`, platform guards, or back-button modifiers needed in the folder itself.

Tapping (or pressing the appropriate key or remote button) advances to the next variant. Reaching the last variant wraps back to the first.

All members must be accessed on the **main actor**.

### Basic Usage

```swift
var view: some View {
    HarnessPreview([Style.compact, .regular, .expanded]) { style in
        MyComponent(style: style)
    }
}
```

### Bool Shorthand

Omit the array when cycling between two states. The view starts with `false` and advances to `true` on the first interaction:

```swift
var view: some View {
    HarnessPreview { isOn in
        Toggle("Feature", isOn: .constant(isOn))
    }
}
```

### Platform Behaviour

| Platform | Trigger |
| :--- | :--- |
| iOS, watchOS, visionOS | Tap anywhere in the view |
| macOS 14+ | Tap or down-arrow key |
| macOS 11–13 | Tap only |
| tvOS | Play/Pause remote button |

### HarnessKitTesting Integration

`HarnessKitTesting` adds `advancePreview(app:)` and `iteratePreview(app:variantCount:action:)` to every `PathFolder` case. These methods find `HarnessPreview` via the `"HarnessPreview"` accessibility identifier it sets on itself automatically.

## Parameters

| Name | Type | Description |
| :--- | :--- | :--- |
| `Variant` | `Any` | The type of each variant value passed to the content closure. |
| `Content` | `View` | The SwiftUI view type returned by the content closure. |

## Topics

### Initializers

- ``init(_:content:)``
- ``init(content:)``

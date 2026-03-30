# ``HarnessKit/HarnessPreview/init(_:content:)``

Creates a preview that cycles through the given variants.

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

Pass an ordered array of any value type and a `@ViewBuilder` closure that maps each value to a view. `HarnessPreview` starts at index `0` and advances by one on each user interaction, wrapping back to the beginning after the last variant.

If `variants` is empty the view renders nothing.

```swift
var view: some View {
    HarnessPreview([Style.compact, .regular, .expanded]) { style in
        MyComponent(style: style)
    }
}
```

For a two-state `Bool` toggle, use the shorthand ``init(content:)`` instead.

## Parameters

| Name | Type | Description |
| :--- | :--- | :--- |
| `variants` | `[Variant]` | The ordered list of values to cycle through. |
| `content` | `(Variant) -> Content` | A view builder that receives the current variant and returns the view to display. |

## See Also

- ``HarnessKit/HarnessPreview``
- ``init(content:)``

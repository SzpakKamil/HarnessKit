# ``HarnessKit/HarnessPreview/init(content:)``

Creates a preview that cycles between `false` and `true`.

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

A shorthand for `HarnessPreview([false, true], content:)`. The view starts with `false` and advances to `true` on the first interaction. Subsequent interactions toggle between the two states.

Use this when the component under test has a single boolean property to exercise:

```swift
var view: some View {
    HarnessPreview { isOn in
        Toggle("Feature", isOn: .constant(isOn))
    }
}
```

For three or more states, or for non-`Bool` value types, use ``init(_:content:)`` with an explicit array.

## Parameters

| Name | Type | Description |
| :--- | :--- | :--- |
| `content` | `(Bool) -> Content` | A view builder that receives the current `Bool` value and returns the view to display. |

## See Also

- ``HarnessKit/HarnessPreview``
- ``init(_:content:)``

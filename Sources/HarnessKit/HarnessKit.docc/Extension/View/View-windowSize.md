# ``SwiftUICore/View/windowSize(_:)``

@Metadata {
    @SupportedLanguage(swift)
    @Available(macOS, introduced: "11.0")
    @DocumentationExtension(mergeBehavior: override)
}


Resizes and repositions the first application window when the view appears.

## Overview

`windowSize(_:)` reads `NSApplication.shared.windows.first` in `onAppear` and calls `setFrame(_:display:)` followed by `center()`. Apply it to the root view of your macOS transformer app to ensure the window opens at a consistent size.

```swift
HarnessView(project: MyProject.self)
    .windowSize(.screen)              // fill visible screen area
    .windowSize(.custom(width: 1440, height: 900))  // fixed size, centered
```

> Note: Only the first `NSApplication` window is affected. On non-macOS platforms this modifier does nothing.

## Parameters

| Name | Type | Description |
| :--- | :--- | :--- |
| `mode` | `WindowSizeMode` | `.screen` to fill the display, or `.custom(width:height:)` for a fixed size. |

## See Also

- ``WindowSizeMode``

# ``HarnessKit/WindowSizeMode``

@Metadata {
    @SupportedLanguage(swift)
    @Available(macOS, introduced: "11.0")
    @DocumentationExtension(mergeBehavior: override)
}

@Options {
    @AutomaticSeeAlso(disabled)
}

Controls how a window is sized when it appears.

## Overview

Pass a `WindowSizeMode` to the `windowSize(_:)` view modifier to set the macOS window frame in `onAppear`. Two modes are available:

- `.screen` — expands the window to fill the visible screen area.
- `.custom(width:height:)` — sets a fixed size and centers the window on screen.

```swift
HarnessView(project: MyProject.self)
    .windowSize(.custom(width: 1200, height: 800))
```

## Topics

### Cases

- ``screen``
- ``custom(width:height:)``

## See Also

- ``SwiftUICore/View/windowSize(_:)``

# ``HarnessKit``

A structured navigation harness for SwiftUI demo apps and component previews.

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

`HarnessKit` organizes SwiftUI component previews into a type-safe, navigable tree. Conform a root type to ``PathProject``, group related views into ``PathFolder`` enums, and render the lot with ``HarnessView``. Pair it with `HarnessKitTesting` to drive any screen from a UI test in one call.

The package ships four libraries you mix into your project:

| Library | Role |
|---|---|
| `HarnessKit` | Navigation harness: ``PathProject``, ``PathFolder``, ``HarnessView``, ``HarnessPreview`` |
| `HarnessKitTesting` | UI test helpers: `navigate(app:)`, `iteratePreview(app:variantCount:action:)` |
| `HarnessKitScreenshots` | Screenshot metadata: `Screenshot`, `ScreenOrientation`, `TargetOS`, `ScreenshotAppearance` |
| `HarnessKitScreenshotTesting` | Screenshot capture: `captureScreenshot(...)`, `updateOrientation(phone:pad:)`, `resetTheme(to:)` |

Link `HarnessKit` against the app target. Link `HarnessKitTesting` and `HarnessKitScreenshotTesting` against the UI test target.

## Getting Started

@Links(visualStyle: detailedGrid) {
    - <doc:AboutHarnessKit>
    - <doc:SetUp>
    - <doc:ChoosingATarget>
    - <doc:HarnessUsage>
}

## Topics

### Essentials

- <doc:AboutHarnessKit>
- <doc:SetUp>
- <doc:ChoosingATarget>
- <doc:HarnessUsage>

### Core Types

- ``HarnessKit/HarnessView``
- ``HarnessKit/PathProject``
- ``HarnessKit/PathFolder``
- ``HarnessKit/PathComponent``
- ``HarnessKit/HarnessPreview``

### Window Management

- ``HarnessKit/WindowSizeMode``
- ``SwiftUICore/View/windowSize(_:)``

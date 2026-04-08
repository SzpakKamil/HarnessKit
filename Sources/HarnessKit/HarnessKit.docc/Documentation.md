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

`HarnessKit` organizes SwiftUI component previews into a type-safe, navigable tree. Conform a root type to `PathProject`, group related views into `PathFolder` enums, and render everything with `HarnessView`. Pair with `HarnessKitTesting` to navigate to any screen in a UI test with one method call.

@Image(source: "HarnessKit-Banner", alt: "HarnessKit banner showing a structured list navigation.")

The full package ships six libraries that compose into a complete screenshot pipeline:

| Library | Role |
|---|---|
| `HarnessKit` | Navigation harness — `PathProject`, `PathFolder`, `HarnessView`, `HarnessPreview` |
| `HarnessKitTesting` | UI-test helpers — `navigate(app:)`, `iteratePreview(app:variantCount:action:)` |
| `HarnessKitScreenshots` | Screenshot metadata types — `Screenshot`, `ScreenshotConfig`, `VersionedBezel` |
| `HarnessKitScreenshotTesting` | Screenshot capture — `captureScreenshot(...)`, `resetTheme(to:)` |
| `HarnessKitTransform` | macOS image pipeline — `transformScreenshot(...)`, `HarnessKitCatalogue` |

Add `HarnessKit` to the app target, `HarnessKitTesting` and `HarnessKitScreenshotTesting` to the UI test target, and `HarnessKitTransform` to the macOS transformer app.

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

# ``HarnessKitTesting``

Automated UI navigation for HarnessKit hierarchies across all Apple platforms.

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

`HarnessKitTesting` adds `navigate(app:)` to every `PathFolder` case. Call it from a UI test and the library drives the app to that screen automatically. On iOS and watchOS it scrolls and taps by label. On macOS it clicks with scroll fallback. On tvOS it activates the app and sends `XCUIRemote` directional presses calculated from the hierarchy's integer path indices.

For cases whose `view` uses `HarnessPreview`, `advancePreview(app:)` steps forward one variant and `iteratePreview(app:variantCount:action:)` visits all variants in sequence, calling a closure at each step.

Link `HarnessKitTesting` to your UI test target only. Do not add it to the main app target.

## Getting Started

@Links(visualStyle: detailedGrid) {
    - <doc:AboutHarnessKitTesting>
    - <doc:SetUpTesting>
}

## Topics

### Essentials

- <doc:AboutHarnessKitTesting>
- <doc:SetUpTesting>

### Navigation

- ``HarnessKit/PathFolder/navigate(app:)-1ajjy``
- ``HarnessKit/PathFolder/navigate(app:)-kwcb``
- ``HarnessKit/PathFolder/advancePreview(app:)``
- ``HarnessKit/PathFolder/advancePreview(app:steps:)``
- ``HarnessKit/PathFolder/iteratePreview(app:variantCount:action:)``

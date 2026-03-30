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

All members must be accessed on the main actor.

@Image(source: "HarnessKit-Banner", alt: "HarnessKit banner showing a structured list navigation.")

## Getting Started

@Links(visualStyle: detailedGrid) {
    - <doc:AboutHarnessKit>
    - <doc:SetUp>
    - <doc:HarnessUsage>
}

## Topics

### Essentials

- <doc:AboutHarnessKit>
- <doc:SetUp>
- <doc:HarnessUsage>

### Core Types

- ``HarnessKit/HarnessView``
- ``HarnessKit/PathProject``
- ``HarnessKit/PathFolder``

# ``HarnessKitTransform/resolveBezel(from:for:bezelType:)``

@Metadata {
    @SupportedLanguage(swift)
    @Available(macOS, introduced: "11.0")
    @DocumentationExtension(mergeBehavior: override)
}

@Options {
    @AutomaticArticleSubheading(disabled)
}

Picks the best-matching bezel for a screenshot from a versioned config array.

## Overview

`resolveBezel` iterates the `candidates` array looking for the first `VersionedBezel` whose `[minVersion, maxVersion)` range includes `screenshot.osVersion`. When a match is found, it resolves the `bezelID` to a concrete `BezelDescriptor` case via `B.bezel(for:)`.

If `screenshot.osVersion` is `nil` or no range matches, the function falls back to the last entry in the array.

Platform processors call this function internally. Call it directly only when building a custom pipeline.

## Parameters

| Name | Type | Description |
| :--- | :--- | :--- |
| `candidates` | `[VersionedBezel]` | The versioned bezel array from `ScreenshotConfig`. |
| `screenshot` | `Screenshot` | The screenshot whose `osVersion` drives selection. |
| `bezelType` | `B.Type` | The concrete `BezelDescriptor` type to resolve into. |

## Returns

The matching `BezelDescriptor` case, or `nil` if the array is empty or no ID resolves.

## Example

```swift
let bezel = resolveBezel(from: config.phoneBezel, for: screenshot, bezelType: PhoneBezel.self)
```

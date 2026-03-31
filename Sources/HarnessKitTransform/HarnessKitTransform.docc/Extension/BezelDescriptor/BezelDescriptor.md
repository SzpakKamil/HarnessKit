# ``HarnessKitTransform/BezelDescriptor``

@Metadata {
    @SupportedLanguage(swift)
    @Available(macOS, introduced: "11.0")
    @DocumentationExtension(mergeBehavior: override)
}

@Options {
    @AutomaticSeeAlso(disabled)
}

A protocol that all device bezel enums conform to.

## Overview

`BezelDescriptor` is the common interface for `PhoneBezel`, `PadBezel`, `WatchBezel`, `MacBezel`, and `OtherBezel`. The transform pipeline uses this protocol to:

- Load the border PNG via `borderImage(os:appearance:)` from `Bundle.module`.
- Load the screen-shape mask PNG via `maskImage()`.
- Resolve a case by string ID via `bezel(for:)`.
- Group cases by device model for display in the Tester app via `groupedByStyle()`.

The protocol also provides `Codable` conformance via a single-value encode/decode using the case's `id` property.

### Required properties

| Property | Description |
| :--- | :--- |
| `id` | Stable string identifier matching the PNG filename in the bundle. |
| `shortID` | Short string used to construct the mask filename (`"\(shortID)Mask.png"`). |
| `prettyName` | Human-readable color/variant name shown in the Tester UI. |
| `model` | Device model string, e.g. `"iPhone 17 Pro"`. |
| `runDestination` | Xcode simulator name for this device. |
| `scale` | Factor by which the screenshot is shrunk before placement (0–1). |
| `verticalOffset` | Vertical shift in points applied when placing the screenshot inside the bezel. |

## Topics

### Required Interface

- ``id``
- ``shortID``
- ``prettyName``
- ``model``
- ``runDestination``
- ``scale``
- ``verticalOffset``
- ``bezel(for:)``

### Provided by Extension

- ``borderImage(os:appearance:)``
- ``maskImage()``
- ``groupedByStyle()``

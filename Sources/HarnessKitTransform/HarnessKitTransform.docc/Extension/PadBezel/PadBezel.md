# ``HarnessKitTransform/PadBezel``

@Metadata {
    @SupportedLanguage(swift)
    @Available(macOS, introduced: "11.0")
    @DocumentationExtension(mergeBehavior: override)
}

@Options {
    @AutomaticSeeAlso(disabled)
}

Device bezels for iPad models.

## Overview

`PadBezel` covers iPad 9th Gen, iPad mini A17 Pro, iPad Air 11"/13" M2, and iPad Pro 11"/13" M4. All cases use a `verticalOffset` of `0`. Scale factors range from `0.88` (iPad 9th Gen) to `0.92` (iPad Air 13", iPad Pro).

```swift
config.padBezel = [
    VersionedBezel(minVersion: "16.0", bezelID: PadBezel.`iPad Pro 13" M4 Silver`.id)
]
```

## Topics

### iPad 9th Gen

- ``iPad 9th Gen Silver``

### iPad mini

- ``iPad mini A17 Pro Starlight``

### iPad Air 11" M2

- ``iPad Air 11" M2 Blue``
- ``iPad Air 11" M2 Purple``
- ``iPad Air 11" M2 Space Gray``
- ``iPad Air 11" M2 Stardust``

### iPad Air 13" M2

- ``iPad Air 13" M2 Blue``
- ``iPad Air 13" M2 Purple``
- ``iPad Air 13" M2 Space Gray``
- ``iPad Air 13" M2 Stardust``

### iPad Pro 11" M4

- ``iPad Pro 11" M4 Silver``
- ``iPad Pro 11" M4 Space Gray``

### iPad Pro 13" M4

- ``iPad Pro 13" M4 Silver``
- ``iPad Pro 13" M4 Space Gray``

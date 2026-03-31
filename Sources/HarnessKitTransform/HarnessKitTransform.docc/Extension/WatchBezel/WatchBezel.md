# ``HarnessKitTransform/WatchBezel``

@Metadata {
    @SupportedLanguage(swift)
    @Available(macOS, introduced: "11.0")
    @DocumentationExtension(mergeBehavior: override)
}

@Options {
    @AutomaticSeeAlso(disabled)
}

Device bezels for Apple Watch models.

## Overview

`WatchBezel` covers Apple Watch Series 11 (42 mm and 46 mm) and Apple Watch Ultra 3 (49 mm) in all available band and case combinations.

Scale factors: Series 11 cases use `0.75`; Ultra 3 cases use `0.72`. All use a `verticalOffset` of `0`.

```swift
config.watchBezel = [
    VersionedBezel(
        minVersion: "11.0",
        bezelID: WatchBezel.`Apple Watch S11 46mm Aluminum Jet Black Sport Band Black`.id
    )
]
```

## Topics

### Apple Watch Series 11 42mm — Sport Loop

- ``Apple Watch S11 42mm Aluminum Jet Black Sport Loop Dark Grey``
- ``Apple Watch S11 42mm Aluminum Rose Gold Sport Loop Purple Fog``
- ``Apple Watch S11 42mm Aluminum Silver Sport Loop Forest``
- ``Apple Watch S11 42mm Aluminum Silver Sport Loop Neon Yellow``
- ``Apple Watch S11 42mm Aluminum Space Gray Sport Loop Anchor Blue``
- ``Apple Watch S11 42mm Aluminum Space Gray Sport Loop Forest``

### Apple Watch Series 11 42mm — Sport Band

- ``Apple Watch S11 42mm Aluminum Jet Black Sport Band Black``
- ``Apple Watch S11 42mm Aluminum Rose Gold Sport Band Light Blush``
- ``Apple Watch S11 42mm Aluminum Silver Sport Band Neon Yellow``
- ``Apple Watch S11 42mm Aluminum Silver Sport Band Purple Fog``
- ``Apple Watch S11 42mm Aluminum Space Gray Sport Band Anchor Blue``
- ``Apple Watch S11 42mm Aluminum Space Gray Sport Band Black``
- ``Apple Watch S11 42mm Titanium Gold Sport Band Light Blush``
- ``Apple Watch S11 42mm Titanium Gold Sport Band Purple Fog``
- ``Apple Watch S11 42mm Titanium Natural Sport Band Stone Gray``
- ``Apple Watch S11 42mm Titanium Slate Sport Band Black``

### Apple Watch Series 11 46mm — Sport Loop

- ``Apple Watch S11 46mm Aluminum Jet Black Sport Loop Dark Grey``
- ``Apple Watch S11 46mm Aluminum Rose Gold Sport Loop Purple Fog``
- ``Apple Watch S11 46mm Aluminum Silver Sport Loop Forest``
- ``Apple Watch S11 46mm Aluminum Silver Sport Loop Neon Yellow``
- ``Apple Watch S11 46mm Aluminum Space Gray Sport Loop Anchor Blue``
- ``Apple Watch S11 46mm Aluminum Space Gray Sport Loop Forest``

### Apple Watch Series 11 46mm — Sport Band

- ``Apple Watch S11 46mm Aluminum Jet Black Sport Band Black``
- ``Apple Watch S11 46mm Aluminum Rose Gold Sport Band Light Blush``
- ``Apple Watch S11 46mm Aluminum Silver Sport Band Neon Yellow``
- ``Apple Watch S11 46mm Aluminum Silver Sport Band Purple Fog``
- ``Apple Watch S11 46mm Aluminum Space Gray Sport Band Anchor Blue``
- ``Apple Watch S11 46mm Aluminum Space Gray Sport Band Black``
- ``Apple Watch S11 46mm Titanium Gold Sport Band Light Blush``
- ``Apple Watch S11 46mm Titanium Gold Sport Band Purple Fog``
- ``Apple Watch S11 46mm Titanium Natural Sport Band Stone Gray``
- ``Apple Watch S11 46mm Titanium Slate Sport Band Black``

### Apple Watch Ultra 3

- ``Apple Watch Ultra 3 Black Alpine Loop Black``
- ``Apple Watch Ultra 3 Black Alpine Loop Light Blue``
- ``Apple Watch Ultra 3 Natural Alpine Loop Light Blue``
- ``Apple Watch Ultra 3 Natural Alpine Loop Terra Cotta``
- ``Apple Watch Ultra 3 Black Milanese Loop``
- ``Apple Watch Ultra 3 Natural Milanese Loop``
- ``Apple Watch Ultra 3 Black Ocean Band Anchor Blue``
- ``Apple Watch Ultra 3 Black Ocean Band Black``
- ``Apple Watch Ultra 3 Natural Ocean Band Anchor Blue``
- ``Apple Watch Ultra 3 Natural Ocean Band Neon Green``
- ``Apple Watch Ultra 3 Black Trail Loop Black Charcoal``
- ``Apple Watch Ultra 3 Natural Trail Loop Blue Bright Blue``
- ``Apple Watch Ultra 3 Natural Trail Loop Green Neon``

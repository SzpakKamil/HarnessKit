# ``HarnessKitTransform/MacBezel``

@Metadata {
    @SupportedLanguage(swift)
    @Available(macOS, introduced: "11.0")
    @DocumentationExtension(mergeBehavior: override)
}

@Options {
    @AutomaticSeeAlso(disabled)
}

Device bezels for Mac models.

## Overview

`MacBezel` covers MacBook Air 13" (4th gen), MacBook Pro 14"/16" M4, and iMac 24". Mac bezels require both `os` and `appearance` when loading border images, because each Mac model ships separate PNGs for light and dark macOS appearances and different macOS versions (Sequoia, Tahoe).

Scale factors and vertical offsets vary per model:

| Case | Scale | Vertical Offset |
| :--- | :--- | :--- |
| MacBook Air 13" 4th-gen Midnight | 0.72 | +14 |
| MacBook Pro 14" M4 Silver | 0.76 | −15 |
| MacBook Pro 16" M4 Silver | 0.79 | −14 |
| iMac 24" Silver | 0.73 | +250 |

```swift
config.macBezel = [
    VersionedBezel(minVersion: "15.0", bezelID: MacBezel.`Macbook Pro 16" M4 Silver`.id)
]
```

## Topics

### Cases

- ``Macbook Air 13" 4th-gen Midnight``
- ``Macbook Pro 14" M4 Silver``
- ``Macbook Pro 16" M4 Silver``
- ``iMac 24" Silver``

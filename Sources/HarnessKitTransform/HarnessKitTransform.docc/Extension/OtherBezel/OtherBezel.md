# ``HarnessKitTransform/OtherBezel``

@Metadata {
    @SupportedLanguage(swift)
    @Available(macOS, introduced: "11.0")
    @DocumentationExtension(mergeBehavior: override)
}

@Options {
    @AutomaticSeeAlso(disabled)
}

Device bezels for Apple TV.

## Overview

`OtherBezel` currently contains one case: `Apple TV Frame`, the decorative border used for tvOS screenshots. The bezel scale is `0.995` and vertical offset is `0`.

```swift
config.tvBezel = [
    VersionedBezel(minVersion: "18.0", bezelID: OtherBezel.`Apple TV Frame`.id)
]
```

## Topics

### Cases

- ``Apple TV Frame``

# ``HarnessKitTransform/PhoneBezel``

@Metadata {
    @SupportedLanguage(swift)
    @Available(macOS, introduced: "11.0")
    @DocumentationExtension(mergeBehavior: override)
}

@Options {
    @AutomaticSeeAlso(disabled)
}

Device bezels for iPhone models.

## Overview

`PhoneBezel` covers every iPhone available as a simulator bezel asset in the bundle, from iPhone 16 through iPhone 17 and iPhone Air. Use a `PhoneBezel` case as the `bezelID` in a `VersionedBezel` entry inside `ScreenshotConfig.phoneBezel`.

```swift
config.phoneBezel = [
    VersionedBezel(minVersion: "16.0", maxVersion: "26.0", bezelID: PhoneBezel.`iPhone 16 Black`.id),
    VersionedBezel(minVersion: "26.0", bezelID: PhoneBezel.`iPhone 17 Black`.id)
]
```

All iPhone bezels use a `verticalOffset` of `0`. Scale factors range from `0.935` (iPhone 16) to `0.9575` (iPhone 16/17 Pro Max).

## Topics

### iPhone 17 Series

- ``iPhone 17 Pro Max Cosmic Orange``
- ``iPhone 17 Pro Max Deep Blue``
- ``iPhone 17 Pro Max Silver``
- ``iPhone 17 Pro Cosmic Orange``
- ``iPhone 17 Pro Deep Blue``
- ``iPhone 17 Pro Silver``
- ``iPhone 17 Black``
- ``iPhone 17 Lavender``
- ``iPhone 17 Mist Blue``
- ``iPhone 17 Sage``
- ``iPhone 17 White``

### iPhone Air

- ``iPhone Air Cloud White``
- ``iPhone Air Light Gold``
- ``iPhone Air Sky Blue``
- ``iPhone Air Space Black``

### iPhone 16 Series

- ``iPhone 16 Pro Max Black Titanium``
- ``iPhone 16 Pro Max Desert Titanium``
- ``iPhone 16 Pro Max Natural Titanium``
- ``iPhone 16 Pro Max White Titanium``
- ``iPhone 16 Pro Black Titanium``
- ``iPhone 16 Pro Desert Titanium``
- ``iPhone 16 Pro Natural Titanium``
- ``iPhone 16 Pro White Titanium``
- ``iPhone 16 Plus Black``
- ``iPhone 16 Plus Pink``
- ``iPhone 16 Plus Teal``
- ``iPhone 16 Plus Ultramarine``
- ``iPhone 16 Plus White``
- ``iPhone 16 Black``
- ``iPhone 16 Pink``
- ``iPhone 16 Teal``
- ``iPhone 16 Ultramarine``
- ``iPhone 16 White``

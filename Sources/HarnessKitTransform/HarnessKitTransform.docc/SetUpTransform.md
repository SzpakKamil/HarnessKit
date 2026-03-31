# Set Up Transform

@Metadata {
    @SupportedLanguage(swift)
    @TitleHeading("Getting Started")
    @Available(macOS, introduced: "11.0")
    @Available(swift, introduced: "5.9")
    @Available(Xcode, introduced: "15.0")
    @PageColor(green)
}

@Options {
    @AutomaticSeeAlso(disabled)
}

Add `HarnessKitTransform` to the macOS Tester app and transform raw screenshots into finished App Store images.

## Overview

`HarnessKitTransform` is macOS-only. It uses `AppKit` for all image compositing and reads bezel PNG assets from its module bundle. Link it only to the macOS Tester application target — never to a UI test target or a cross-platform library.

## Adding HarnessKitTransform

1. In Xcode, select **File > Add Packages...**.
2. Enter the HarnessKit repository URL and click **Add Package**.
3. Assign `HarnessKitTransform` to your **macOS app target**. It pulls `HarnessKitScreenshots` in transitively.

## Basic Transform

Load your config, get the raw screenshot image, and call `transformScreenshot`:

```swift
import HarnessKitTransform
import HarnessKitScreenshots

let config = await ScreenshotConfig.load()
let outputDir = URL(fileURLWithPath: "/Users/me/Desktop/Transformed")

let screenshot = Screenshot(
    id: "home",
    appearance: .light,
    os: .iOS,
    osVersion: "18.2",
    backgroundHex: "F2F2F7"
)

do {
    try transformScreenshot(
        image: rawNSImage,
        screenshot: screenshot,
        config: config,
        outputDirectory: outputDir
    )
} catch {
    print("Transform failed: \(error.localizedDescription)")
}
```

The function writes `home-iOS.png` (derived from `screenshot.prettyName()`) into `outputDir`.

## Getting the Image Without Saving

Use `processScreenshot` when you need the composed `NSImage` before deciding what to do with it:

```swift
let result = try processScreenshot(image: rawNSImage, screenshot: screenshot, config: config)

// Preview in a SwiftUI Image, add overlays, etc.
let nsImageView = NSImageView(image: result)

// Then save manually:
try saveResults(image: result, name: "home-custom", to: outputDir)
```

## Custom Pipeline

Every pipeline step is a standalone public function. Compose them in any order:

```swift
let prepared = prepareScreenshot(image: rawNSImage, os: .iOS)
let masked   = maskScreenshot(image: prepared, bezel: myBezel)
let scaled   = scaleToBezel(image: masked, factor: myBezel.scale)
let bezeled  = placeBezel(image: scaled, bezel: bezelImage, verticalOffset: 0, screenshotOnTop: false)
let colored  = addBackgroundColor(image: bezeled, color: "1C1C1E")
let cropped  = cropImage(image: colored, crop: CropRect(x: 0, y: 0, width: 1, height: 1))
let final    = adjustResolution(image: cropped, resolution: .default)
try saveResults(image: final, name: "custom", to: outputDir)
```

## Configuring Bezels

Set per-platform versioned bezels in `ScreenshotConfig`. Each `VersionedBezel` covers a version range; the pipeline picks the first matching entry for `screenshot.osVersion`:

```swift
var config = ScreenshotConfig.defaults
config.phoneBezel = [
    VersionedBezel(minVersion: "16.0", maxVersion: "26.0", bezelID: "iPhone16Black"),
    VersionedBezel(minVersion: "26.0", bezelID: "iPhone17Black")
]
```

Valid `bezelID` values are the `id` properties of the concrete bezel enums: ``PhoneBezel``, ``PadBezel``, ``WatchBezel``, ``MacBezel``, ``OtherBezel``.

## Troubleshooting

- **`TransformError.bezelNotFound`**: The `bezelID` in your config does not match any case in the target bezel enum. Print `PhoneBezel.allCases.map(\.id)` to see valid IDs.
- **`TransformError.bezelImageMissing`**: A PNG asset for the resolved bezel ID is missing from the module bundle. Verify the file exists in `Sources/HarnessKitTransform/Resources/Bezzels/`.
- **Bezel resolution always returns the last entry**: `screenshot.osVersion` is `nil`. Set it when constructing the `Screenshot` or when parsing attachment names.
- **Linking error on iOS**: `HarnessKitTransform` must not be linked to any non-macOS target. Check the target membership of the module in Xcode.

## Next Steps

- <doc:HarnessKitTransform>
- <doc:AboutHarnessKitTransform>

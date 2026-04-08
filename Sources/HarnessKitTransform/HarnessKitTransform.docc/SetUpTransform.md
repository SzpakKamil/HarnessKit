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

Add `HarnessKitTransform` to your macOS transformer app and process raw screenshots into finished images.

## Overview

`HarnessKitTransform` is **macOS-only**. It uses `AppKit` for all image compositing. Link it only to your macOS transformer application target — never to a UI test target or a cross-platform library.

## Adding HarnessKitTransform

1. In Xcode, select **File > Add Packages...**.
2. Enter the HarnessKit repository URL and click **Add Package**.
3. Assign `HarnessKitTransform` to your **macOS app target**. It pulls `HarnessKitScreenshots` in transitively.

> Important: Do not link `HarnessKitTransform` to any non-macOS target. It will not compile on iOS, tvOS, watchOS, or visionOS.

## App Launch Setup

Fetch the R2 manifest on launch so bezel downloads work:

```swift
// In App.swift .task:
try await HarnessKitCatalogue.shared.refresh()
```

This downloads the manifest and catalogue JSONs. Stale cache objects from previous manifests are evicted automatically.

## Basic Transform

Load your config from Application Support, prefetch bezels, then transform:

```swift
import HarnessKitTransform
import HarnessKitScreenshots

let config = ScreenshotConfig.load(from: myConfigURL)

// Prefetch bezels before the batch
try await HarnessKitCatalogue.shared.prefetch(for: config)

let screenshot = Screenshot(
    id: "home",
    appearance: .light,
    background: .solid(hex: "F2F2F7"),
    shadows: [.drop(DropShadow(opacity: 0.4, blur: 0.02))]
)

try transformScreenshot(
    image: rawNSImage,
    screenshot: screenshot,
    config: config,
    outputDirectory: outputURL
)
```

## Getting the Image Without Saving

Use `processScreenshot` when you need the `NSImage` for preview or further processing:

```swift
let result = try processScreenshot(image: rawNSImage, screenshot: screenshot, config: config)
// Preview in SwiftUI, add overlays, etc.
```

## Using the Unified Pipeline Directly

`applyBezelPipeline(image:params:)` gives you full control via ``BezelPipelineParams``:

```swift
let descriptor = try DeviceDescriptor.descriptor(for: "iPhone17", in: DeviceDescriptor.allPhone)
let bezelImage = try descriptor.bezelImage(color: "Black")

let params = BezelPipelineParams(
    os: .iOS,
    bezelImage: bezelImage,
    scale: descriptor.scale,
    verticalOffset: descriptor.verticalOffset,
    horizontalOffset: descriptor.horizontalOffset,
    cornerRadius: descriptor.screenCornerRadius,
    screenshotOnTop: false,
    background: .solid(hex: "F2F2F7"),
    shadows: [.drop(DropShadow())],
    resolution: .full
)
let result = applyBezelPipeline(image: rawNSImage, params: params)
```

## Multi-Device Composition

Compose multiple devices on a single canvas:

```swift
let iphone = applyBezelPipeline(image: phoneShot, params: phoneParams)
let mac = applyBezelPipeline(image: macShot, params: macParams)

let canvas = composeCanvas(
    layers: [
        CanvasLayer(image: mac, x: -0.3, y: 0, scale: 1.0),
        CanvasLayer(image: iphone, x: 0.35, y: 0, scale: 1.0)
    ],
    canvasSize: NSSize(width: 2089, height: 1440),
    background: .gradient(startHex: "E0E7FF", endHex: "FFFFFF", angle: 180)
)
```

## Configuring Bezels

The config is owned by your project — load it from Application Support or build programmatically:

```swift
var config = ScreenshotConfig.defaults
config.phoneBezel = [
    VersionedBezel(minVersion: "16.0", maxVersion: "26.0", deviceID: "iPhone16", color: "Black"),
    VersionedBezel(minVersion: "26.0", deviceID: "iPhone17", color: "Black")
]
```

Print `DeviceDescriptor.allPhone.map(\.id)` to see available phone identifiers. For Mac: `MacDeviceDescriptor.all.map(\.id)`. For Watch: `WatchDeviceDescriptor.all.map(\.id)`.

## Troubleshooting

- **`TransformError.bezelNotFound`**: No `VersionedBezel` in your config matches `screenshot.osVersion`. Check your version ranges.
- **`TransformError.bezelFileNotFound`**: Bezel PNG not in cache or bundle. Run `HarnessKitCatalogue.shared.prefetch(for: config)`.
- **`TransformError.notInManifest`**: Bezel paths missing from the R2 manifest. Regenerate the manifest with `generate_manifest.py --pull-r2-bezels`.
- **`TransformError.descriptorNotFound`**: `deviceID` not in catalogue JSON. Print the `.all` array for the relevant platform to see valid IDs.
- **Bezel always picks the last entry**: `screenshot.osVersion` is `nil`. Use `ScreenshotMetadata/read(from:)` to get the full `Screenshot` from the PNG metadata instead of parsing the filename.
- **Linking error on iOS**: `HarnessKitTransform` must not be linked to any non-macOS target.

## Next Steps

- <doc:HarnessKitTransform>
- <doc:AboutHarnessKitTransform>

# About HarnessKitTransform

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

Turn raw screenshots into polished App Store images with device bezels, shadows, and backgrounds.

## Overview

`HarnessKitTransform` receives a raw `NSImage` and a `Screenshot` metadata value, then runs it through a deterministic pipeline that produces a finished composition.

### Pipeline Steps

1. **Prepare** — rotate landscape iOS/iPadOS screenshots upright.
2. **Mask** — clip to the device's screen corner radius.
3. **Scale** — shrink the screenshot to fit inside the bezel using the calibrated scale factor.
4. **Place bezel** — composite the screenshot and bezel PNG together. If the bezel is larger than the output resolution, it is pre-scaled for performance.
5. **Orient** — rotate the composed image for landscape output.
6. **Place on canvas** — scale-to-fit the composition onto the resolution canvas.
7. **Shadows** — apply drop shadows (bezel silhouette) and shape shadows (contact ellipses). Shape shadows with the same blur radius are batched into a single GPU pass.
8. **Background** — fill behind the device with a solid color, gradient, or image.
9. **Crop** — apply the `CropRect` pan-and-zoom.

Every step checks `Task.isCancelled` and bails early if the calling task is cancelled. No-op steps (identity crop, same-size resolution, scale factor 1.0) are skipped automatically.

### Entry Points

| Function | Returns | Saves |
| :--- | :--- | :--- |
| `processScreenshot(image:screenshot:config:)` | `NSImage` | No |
| `transformScreenshot(image:screenshot:config:outputDirectory:)` | — | Yes |
| `applyBezelPipeline(image:params:)` | `NSImage` | No |

### Multi-Device Composition

`composeCanvas(layers:canvasSize:background:)` overlays multiple device renders onto a single canvas. Each ``CanvasLayer`` specifies position (x/y from center) and scale. Use this for marketing compositions showing multiple devices side by side.

## Bezel Selection

Each platform processor calls `ScreenshotConfig/matchedBezel(for:)` to pick the `VersionedBezel` whose version range covers `Screenshot/osVersion`. The chosen entry's `deviceID` resolves to a device descriptor (``DeviceDescriptor``, ``MacDeviceDescriptor``, or ``WatchDeviceDescriptor``), which loads the bezel PNG from:

1. **Local object cache** — populated by `HarnessKitCatalogue.shared.prefetch(for:)`
2. **Bundle fallback** — baseline bezels shipped with the SPM package

Call `HarnessKitCatalogue.shared.refresh()` on app launch and `prefetch(for: config)` before each transform batch. Downloads retry up to 2 times with exponential backoff. If a bezel path is missing from the manifest, `TransformError.notInManifest` is thrown with the list of missing paths.

### Decoration-Only Devices

Devices with `allowsScreenshot: false` (e.g. Apple TV box, Vision Pro goggles) are loaded as static images — no screenshot placement or pipeline processing. They are only usable in the Canvas Composer, not the standard transform pipeline.

## Error Handling

All functions throw ``TransformError``:

| Error | Meaning |
| :--- | :--- |
| `.bezelNotFound(screenshotID:)` | No `VersionedBezel` in config matches this screenshot |
| `.bezelImageMissing(bezelID:)` | Descriptor found but bezel PNG not in cache or bundle |
| `.bezelFileNotFound(id:color:)` | Specific bezel file not found |
| `.descriptorNotFound(id:catalogue:)` | Device ID not in catalogue JSON |
| `.cannotParseDeviceID(id:)` | Device ID format unrecognizable |
| `.notInManifest(paths:)` | Bezel paths missing from R2 manifest |
| `.manifestNotLoaded` | `refresh()` not called or failed |
| `.imageSaveFailed(url:error:)` | PNG write to disk failed |

## Cache Management

After `refresh()`, stale cached objects not referenced by the new manifest are automatically evicted. Call `HarnessKitCatalogue.shared.evictStaleCache()` manually to trigger eviction at any time.

## Device Imagery Notice

The bezel images fetched by `HarnessKitCatalogue` depict Apple hardware and are the intellectual property of Apple Inc. They are used in accordance with Apple's [App Store Marketing Guidelines](https://developer.apple.com/app-store/marketing/guidelines/).

**Permitted use:** Bezel images may only frame screenshots of your own application for App Store promotion.

Apple, iPhone, iPad, Apple Watch, Apple TV, and Mac are trademarks of Apple Inc.

## Next Steps

- <doc:SetUpTransform>
- <doc:HarnessKitTransform>

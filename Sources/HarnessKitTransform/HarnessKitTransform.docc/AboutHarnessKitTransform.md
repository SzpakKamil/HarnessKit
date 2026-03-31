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

Turn raw XCTest screenshots into polished App Store images with device bezels, backgrounds, and precise cropping.

## Overview

`HarnessKitTransform` receives a raw `NSImage` and a `Screenshot` metadata value, then runs it through a deterministic pipeline:

1. **Prepare** — normalise the image size; add a drop shadow on macOS; rotate landscape iOS screenshots upright.
2. **Mask** — clip the screenshot to the device's screen shape using a PNG mask.
3. **Scale** — shrink the screenshot to fit inside the bezel art using the bezel's calibrated scale factor.
4. **Place bezel** — composite the screenshot and bezel PNG together.
5. **Orient** — rotate the composed image for landscape output.
6. **Background** — fill the canvas with the hex color from the `Screenshot`.
7. **Crop** — apply the normalized pan-and-zoom `CropRect`.
8. **Resize** — scale to the final `ScreenshotResolution` canvas.
9. **Save** — write a PNG to the output directory.

Each step is a standalone public function. Call them individually to build a custom pipeline, or call `processScreenshot(image:screenshot:config:)` to run all steps at once and get back an `NSImage`.

## Two Entry Points

**`processScreenshot`** runs the full pipeline and returns an `NSImage`. Use this when you need the result for further work — for example, adding a text overlay or previewing in a SwiftUI view — before saving.

```swift
let result = try processScreenshot(image: rawImage, screenshot: screenshot, config: config)
// do something with result
try saveResults(image: result, name: screenshot.prettyName(), to: outputURL)
```

**`transformScreenshot`** runs the pipeline and saves the PNG in one call. Pass the output directory and the function handles the rest.

```swift
try transformScreenshot(
    image: rawImage,
    screenshot: screenshot,
    config: config,
    outputDirectory: URL(fileURLWithPath: "/Users/me/Desktop/Screenshots")
)
```

## Bezel Selection

The transform pipeline reads `ScreenshotConfig` to resolve which bezel PNG to use. Each platform stores a `[VersionedBezel]` array, and `resolveBezel(from:for:bezelType:)` picks the entry whose version range covers `screenshot.osVersion`. If no range matches, it falls back to the last entry in the array.

Bezel PNG assets ship inside the module bundle (`Resources/Bezzels/` and `Resources/Masks/`). `BezelDescriptor.borderImage(os:appearance:)` and `BezelDescriptor.maskImage()` load them via `Bundle.module`.

## Error Handling

Every platform processor and `saveResults` throws `TransformError` instead of calling `fatalError`. Handle errors at the call site:

```swift
do {
    try transformScreenshot(image: image, screenshot: screenshot, config: config, outputDirectory: dir)
} catch TransformError.bezelNotFound(let id) {
    print("No bezel configured for screenshot '\(id)'")
} catch {
    print("Transform failed: \(error.localizedDescription)")
}
```

## Next Steps

- <doc:SetUpTransform>
- <doc:HarnessKitTransform>

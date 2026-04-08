# Choosing a Target

@Metadata {
    @SupportedLanguage(swift)
    @TitleHeading("Getting Started")
    @Available(iOS, introduced: "14.0")
    @Available(iPadOS, introduced: "14.0")
    @Available(macOS, introduced: "11.0")
    @Available(tvOS, introduced: "14.0")
    @Available(watchOS, introduced: "10.0")
    @Available(visionOS, introduced: "1.0")
    @Available(swift, introduced: "5.9")
    @Available(Xcode, introduced: "15.0")
    @PageColor(blue)
}

@Options {
    @AutomaticSeeAlso(disabled)
}

Understand which HarnessKit libraries to add to each target in your project.

## Overview

The HarnessKit package ships **five libraries** that compose into a complete screenshot pipeline. Each library has a specific role and belongs in a specific Xcode target. Adding the wrong library to the wrong target will cause build errors or include unnecessary dependencies.

## Library Reference

| Library | Role | Link To | Platforms |
| :--- | :--- | :--- | :--- |
| `HarnessKit` | Navigation harness UI — ``PathProject``, ``PathFolder``, ``HarnessView``, ``HarnessPreview`` | **App target** (harness app) | All |
| `HarnessKitTesting` | UI test navigation — `navigate(app:)`, `advancePreview(app:)`, `iteratePreview(app:...)` | **UI test target** | All |
| `HarnessKitScreenshots` | Screenshot metadata types — `Screenshot`, `ScreenshotConfig`, `VersionedBezel`, `ScreenshotShadow`, `ScreenshotBackground`, `ScreenshotMetadata` | **App target** + **macOS transformer** (any target that needs the types) | All |
| `HarnessKitScreenshotTesting` | Screenshot capture — `captureScreenshot(...)`, `updateOrientation(config:)`, `resetTheme(to:)` | **UI test target** | All |
| `HarnessKitTransform` | macOS image pipeline — `processScreenshot(...)`, `applyBezelPipeline(...)`, `HarnessKitCatalogue`, `composeCanvas(...)` | **macOS transformer app** only | macOS only |

## Typical Project Setup

A typical project has three Xcode targets that use HarnessKit:

### 1. Harness App (iOS / macOS / tvOS / watchOS)

The app that displays your component previews in a navigable list.

```
Dependencies:
  ✅ HarnessKit
  ✅ HarnessKitScreenshots (if screenshots share types with the app)
  ❌ HarnessKitTesting (XCTest — cannot link to app)
  ❌ HarnessKitScreenshotTesting (XCTest — cannot link to app)
  ❌ HarnessKitTransform (macOS only)
```

### 2. UI Test Target

Runs automated tests that navigate to screens and capture screenshots.

```
Dependencies:
  ❌ HarnessKit (not needed — test target references folder types directly)
  ✅ HarnessKitTesting (navigate to screens)
  ✅ HarnessKitScreenshots (Screenshot types, imported transitively)
  ✅ HarnessKitScreenshotTesting (captureScreenshot, updateOrientation)
  ❌ HarnessKitTransform (macOS only, not for tests)
```

### 3. macOS Transformer App

A macOS app that transforms raw screenshots into finished App Store images with device bezels, shadows, and backgrounds. This is not a test target — it does not run tests, it processes the PNG attachments exported from test runs.

```
Dependencies:
  ✅ HarnessKit (if it also serves as a harness app)
  ✅ HarnessKitScreenshots (Screenshot and config types)
  ❌ HarnessKitTesting (not a test target)
  ❌ HarnessKitScreenshotTesting (not a test target)
  ✅ HarnessKitTransform (image pipeline)
```

## What Each Library Contains

### HarnessKit

- Protocol tree: ``PathProject`` → ``PathFolder`` → ``PathComponent``
- SwiftUI views: ``HarnessView``, ``HarnessPreview``
- Window sizing: `WindowSizeMode`, `windowSize(_:)`
- No screenshot or transform logic

### HarnessKitTesting

- `navigate(app:)` — programmatic UI test navigation to any ``PathFolder`` case
- `advancePreview(app:)` / `iteratePreview(app:...)` — variant cycling
- Platform-aware: taps on iOS, clicks on macOS, remote presses on tvOS, Digital Crown on watchOS
- Requires `XCTest` — test target only

### HarnessKitScreenshots

- `Screenshot` — describes what to capture and how to transform it
- `ScreenshotConfig` / `VersionedBezel` — per-platform bezel selection
- `ScreenshotShadow` / `DropShadow` / `ShapeShadow` — shadow effects
- `ScreenshotBackground` — solid, gradient, or image canvas fills
- `ScreenshotMetadata` — embeds/reads `Screenshot` JSON in PNG files
- `CropRect`, `ScreenshotResolution`, `ScreenOrientation`, `TargetOS`
- **No XCTest dependency** — safe for any target on any platform

### HarnessKitScreenshotTesting

- `captureScreenshot(screenshot:app:add:)` — sets appearance, captures, attaches PNG
- `updateOrientation(config:)` — rotates iOS simulator from config
- `resetTheme(to:)` / `currentTheme()` — appearance management
- Embeds full `Screenshot` (including shadows) as JSON in PNG metadata
- Requires `XCTest` — test target only

### HarnessKitTransform

- `processScreenshot(...)` / `transformScreenshot(...)` — full platform pipeline
- `applyBezelPipeline(...)` — bezel compositing with shadows and backgrounds
- `composeCanvas(...)` — multi-device canvas composition
- `HarnessKitCatalogue` — downloads bezels from R2, manages local cache
- Device descriptors for iPhone, iPad, Mac, Apple TV, Apple Watch, Vision Pro
- Decoration-only assets (`allowsScreenshot: false`)
- **macOS only**

## Next Steps

- <doc:SetUp>
- <doc:AboutHarnessKit>

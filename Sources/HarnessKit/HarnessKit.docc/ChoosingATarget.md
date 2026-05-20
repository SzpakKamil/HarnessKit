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

Pick the right library for each Xcode target.

## Overview

HarnessKit ships four libraries. Two run inside your app, two run inside a UI test bundle. Add the wrong one to the wrong target and you get link errors at best, an `XCTest` import dragged into a shipping binary at worst.

## Library Reference

| Library | Role | Link To | Platforms |
| :--- | :--- | :--- | :--- |
| `HarnessKit` | Navigation UI: ``PathProject``, ``PathFolder``, ``HarnessView``, ``HarnessPreview`` | App target | All |
| `HarnessKitTesting` | UI test navigation: `navigate(app:)`, `advancePreview(app:)`, `iteratePreview(app:…)` | UI test target | All |
| `HarnessKitScreenshots` | Screenshot metadata: `Screenshot`, `ScreenOrientation`, `TargetOS`, `ScreenshotAppearance` | App target, UI test target | All |
| `HarnessKitScreenshotTesting` | Screenshot capture: `captureScreenshot(…)`, `updateOrientation(phone:pad:)`, `resetTheme(to:)` | UI test target | All |

## Typical Project Layout

You will usually have two Xcode targets that consume HarnessKit.

### 1. The Harness App

The app that renders your component previews.

```
Dependencies:
  HarnessKit                       (required)
  HarnessKitScreenshots            (only if you build Screenshot values in app code)
  HarnessKitTesting                (must not link, pulls in XCTest)
  HarnessKitScreenshotTesting      (must not link, pulls in XCTest)
```

### 2. The UI Test Target

The XCUITest bundle that drives the app and captures screenshots.

```
Dependencies:
  HarnessKit                       (not needed, tests reference folder types directly)
  HarnessKitTesting                (navigate to screens)
  HarnessKitScreenshots            (the Screenshot type)
  HarnessKitScreenshotTesting      (capture and orientation helpers)
```

`HarnessKitScreenshots` carries no `XCTest` dependency, so you can also link it from the app target if you want to construct `Screenshot` values in shared code.

## What Each Library Contains

### HarnessKit

Protocol tree (``PathProject``, ``PathFolder``, ``PathComponent``), the two SwiftUI entry points (``HarnessView``, ``HarnessPreview``), and a macOS-only window helper (``WindowSizeMode``, `View.windowSize(_:)`). No XCTest, no image work.

### HarnessKitTesting

`navigate(app:)` on every ``PathFolder`` case. `advancePreview(app:)` and `iteratePreview(app:…)` for variant cycling. Taps on iOS, clicks on macOS, swipes with the Digital Crown on watchOS, sends remote presses on tvOS. Imports `XCTest`, so it must stay on the test side.

### HarnessKitScreenshots

`Screenshot`, `ScreenshotAppearance`, `ScreenOrientation`, `TargetOS`. The data layer. Safe to link from any target on any platform.

### HarnessKitScreenshotTesting

Five top-level functions: `captureScreenshot`, `updateOrientation`, `setOrientation`, `resetTheme`, `currentTheme`. Sets device appearance, rotates the iOS simulator, captures the screen, attaches a PNG with metadata encoded in the filename. Requires `XCTest`.

## Next Steps

- <doc:SetUp>
- <doc:AboutHarnessKit>

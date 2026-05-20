# About HarnessKitScreenshots

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
    @PageColor(orange)
}

@Options {
    @AutomaticSeeAlso(disabled)
}

The metadata types you build before a screenshot is captured and read after it lands on disk.

## Overview

`HarnessKitScreenshots` carries four public types: ``Screenshot``, ``ScreenshotAppearance``, ``ScreenOrientation``, and ``TargetOS``. None of them touch `XCTest`. None of them render an image. They describe what a screenshot is so other tools can capture it, attach it, or look it up later.

If you want to capture a screenshot from a UI test, you reach for `HarnessKitScreenshotTesting`. If you want to read the screenshot back, you reconstruct a ``Screenshot`` from its filename through ``Screenshot/fromScreenshotName(_:)`` or from JSON through `Codable`.

## The Screenshot Value

``Screenshot`` is the single value the pipeline passes around. Each property maps to a capture-time decision.

| Property | Type | What It Drives |
| :--- | :--- | :--- |
| ``Screenshot/id`` | `String` | The filename stem you use to find this shot later. |
| ``Screenshot/appearance`` | ``ScreenshotAppearance`` | The system theme set on the device before capture. |
| ``Screenshot/os`` | ``TargetOS`` | The Apple platform this shot belongs to. |
| ``Screenshot/orientation`` | ``ScreenOrientation``? | An optional rotation applied before capture (iOS only). |
| ``Screenshot/addBezel`` | `Bool` | Whether a downstream tool should composite a device bezel. |
| ``Screenshot/osVersion`` | `String?` | The OS version the capture infrastructure stamps in. |

Construct one in your test file:

```swift
import HarnessKitScreenshots

let home = Screenshot(
    id: "home",
    appearance: .light,
    os: .iOS,
    addBezel: true
)
```

`os` defaults to ``TargetOS/currentOS``, which inspects the running platform at runtime. `appearance` is required. `osVersion` you do not set yourself: `captureScreenshot` writes it from the live simulator before attaching the PNG.

## Two Serialization Formats

You can move a `Screenshot` between processes in two ways.

### Filename String

``Screenshot/screenshotName()`` flattens the value into a deterministic `key*value^key*value.png` string. It is human-readable and filesystem-safe, which is what makes it useful as an XCTest attachment name:

```
id*home^os*iOS^orientation*nil^appearance*Light^osVersion*26.0.png
```

The encoded keys are `id`, `os`, `orientation`, `appearance`, `osVersion` (when present), and `addBezel` (only when `false`). Parse the string back with ``Screenshot/fromScreenshotName(_:)``.

### Codable JSON

`Screenshot` conforms to `Codable`. Encode it through `JSONEncoder` if you want to embed the full value in PNG `tEXt` metadata, in a sidecar JSON file, or in any other channel that prefers structured data over filename strings.

```swift
let json = try JSONEncoder().encode(home)
```

Both round-trips stay in sync because they encode the same property set.

## Next Steps

- <doc:SetUpScreenshots>
- <doc:HarnessKitScreenshots>

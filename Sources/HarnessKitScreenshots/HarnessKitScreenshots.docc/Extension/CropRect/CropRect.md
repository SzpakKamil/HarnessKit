# ``HarnessKitScreenshots/CropRect``

@Metadata {
    @SupportedLanguage(swift)
    @Available(iOS, introduced: "14.0")
    @Available(iPadOS, introduced: "14.0")
    @Available(macOS, introduced: "11.0")
    @Available(tvOS, introduced: "14.0")
    @Available(watchOS, introduced: "10.0")
    @Available(visionOS, introduced: "1.0")
    @DocumentationExtension(mergeBehavior: override)
}

@Options {
    @AutomaticSeeAlso(disabled)
}

A normalized pan-and-zoom crop applied after bezel compositing.

## Overview

`CropRect` describes how to crop and zoom the composed screenshot before the final resize step. All four values are normalized — they are independent of image resolution.

The default `CropRect(x: 0, y: 0, width: 1, height: 1)` leaves the image unchanged.

### How the values work

Given an image of size *W × H* and a `CropRect`:

- `sourceWidth = W / width`, `sourceHeight = H / height`
- The center of the source rect shifts by `(W − sourceWidth) / 2 × x` horizontally and `(H − sourceHeight) / 2 × y` vertically.
- The cropped region is stretched back to fill the original canvas, so output dimensions never change.

**Zoom in 5% and shift down slightly:**

```swift
CropRect(x: 0, y: -0.05, width: 1.05, height: 1.05)
```

**Zoom in and pan right:**

```swift
CropRect(x: 0.2, y: 0, width: 1.2, height: 1.2)
```

## Topics

### Properties

- ``x``
- ``y``
- ``width``
- ``height``

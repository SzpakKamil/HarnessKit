# ``HarnessKitScreenshots/FillMode``

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

Controls how an image fills a target rect when the aspect ratios differ.

## Overview

Pass `FillMode` to image-compositing helpers to control the scale behavior when the source and destination sizes don't share the same aspect ratio.

- `.fit` — the image scales uniformly until it fits entirely within the target rect, leaving empty space along the shorter axis (letterbox or pillarbox).
- `.fill` — the image scales uniformly until it covers the entire target rect, cropping any overflow along the longer axis.

## Topics

### Cases

- ``fit``
- ``fill``

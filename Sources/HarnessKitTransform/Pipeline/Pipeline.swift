import Foundation
import CoreGraphics
import HarnessKitScreenshots

/// Public namespace for the transform pipeline stages.
///
/// Each stage is a pure function over images — no shared state, no I/O
/// (loaders live on `PlatformImageIO`). Stages compose in any order so
/// callers can build their own variants alongside the standard
/// `Transformer.transform(...)` flow.
public enum Pipeline {

    /// Composes a screenshot inside a device bezel.
    public static func applyBezel(
        to image: PlatformImage,
        params: BezelPipelineParams
    ) -> PlatformImage {
        applyBezelPipeline(image: image, params: params)
    }

    /// Places a device image on a canvas with background, shadows, and optional crop.
    public static func renderOnCanvas(
        _ deviceImage: PlatformImage,
        canvasSize: CGSize,
        background: ScreenshotBackground? = nil,
        backgroundImage: PlatformImage? = nil,
        shadows: [ScreenshotShadow] = [],
        crop: CropRect? = nil,
        positionScale: CGFloat = 1.0,
        positionOffsetX: CGFloat = 0.0,
        positionOffsetY: CGFloat = 0.0,
        canvasPadding: CGFloat = 0.0
    ) -> PlatformImage {
        renderDeviceOnCanvas(
            deviceImage: deviceImage,
            canvasSize: canvasSize,
            background: background,
            backgroundImageCache: backgroundImage,
            shadows: shadows,
            crop: crop,
            positionScale: positionScale,
            positionOffsetX: positionOffsetX,
            positionOffsetY: positionOffsetY,
            canvasPadding: canvasPadding
        )
    }

    /// Renders the given shadows behind `image`, sized relative to `compositionSize`.
    public static func applyShadows(
        to image: PlatformImage,
        shadows: [ScreenshotShadow],
        compositionSize: CGSize,
        compositionCenter: CGPoint
    ) -> PlatformImage {
        HarnessKitTransform.applyShadows(
            image: image,
            shadows: shadows,
            compositionSize: compositionSize,
            compositionCenter: compositionCenter
        )
    }

    /// Applies a background behind the image.
    public static func addBackground(
        to image: PlatformImage,
        background: ScreenshotBackground?,
        backgroundImage: PlatformImage? = nil
    ) -> PlatformImage {
        HarnessKitTransform.addBackground(
            image: image,
            background: background,
            backgroundImageCache: backgroundImage
        )
    }

    /// Resizes the image to match the requested resolution.
    public static func adjustResolution(
        _ image: PlatformImage,
        to resolution: ScreenshotResolution
    ) -> PlatformImage {
        HarnessKitTransform.adjustResolution(image: image, resolution: resolution)
    }

    /// Re-orients a portrait-source image to the requested orientation.
    public static func applyOrientation(
        _ image: PlatformImage,
        orientation: ScreenOrientation
    ) -> PlatformImage {
        HarnessKitTransform.applyOrientation(image: image, orientation: orientation)
    }

    /// Crops the image to a normalized rect (0–1 coordinates).
    public static func crop(
        _ image: PlatformImage,
        to crop: CropRect
    ) -> PlatformImage {
        cropImage(image: image, crop: crop)
    }

    /// Masks the image with a rounded-rect corner radius.
    public static func mask(
        _ image: PlatformImage,
        cornerRadius: CGFloat
    ) -> PlatformImage {
        maskScreenshot(image: image, cornerRadius: cornerRadius)
    }

    /// Places `image` inside `bezel`, scaled and offset to fit.
    public static func placeBezel(
        _ image: PlatformImage,
        bezel: PlatformImage,
        verticalOffset: CGFloat,
        horizontalOffset: CGFloat = 0,
        screenshotOnTop: Bool = false,
        scaleUpToFill: Bool = true,
        nativeScreenSize: CGSize? = nil
    ) -> PlatformImage {
        HarnessKitTransform.placeBezel(
            image: image,
            bezel: bezel,
            verticalOffset: verticalOffset,
            horizontalOffset: horizontalOffset,
            screenshotOnTop: screenshotOnTop,
            scaleUpToFill: scaleUpToFill,
            nativeScreenSize: nativeScreenSize
        )
    }

    /// Rotates a landscape-source screenshot to portrait. Identity on macOS
    /// (where window screenshots are already in their authored orientation)
    /// and on already-portrait inputs.
    public static func normalizeToPortrait(
        _ image: PlatformImage,
        os: TargetOS
    ) -> PlatformImage {
        prepareScreenshot(image: image, os: os)
    }

    /// Scales the image by a uniform factor.
    public static func scale(
        _ image: PlatformImage,
        by factor: CGFloat
    ) -> PlatformImage {
        scaleToBezel(image: image, factor: factor)
    }
}

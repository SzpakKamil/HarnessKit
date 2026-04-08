//
//  BezelPipeline.swift
//  HarnessKitTransform
//

import AppKit
import HarnessKitScreenshots

/// Parameters for the shared bezel pipeline, decoupled from any descriptor type.
///
/// - Important: Instances must be created and consumed on the same
///   thread/task. Do not share across concurrent contexts after creation.
public struct BezelPipelineParams: @unchecked Sendable {
    public let os: TargetOS
    public let bezelImage: NSImage
    public let scale: CGFloat
    public let verticalOffset: CGFloat
    public let horizontalOffset: CGFloat
    public let cornerRadius: CGFloat
    public let screenshotOnTop: Bool
    public let scaleUpToFill: Bool
    public let orientation: ScreenOrientation?
    public let background: ScreenshotBackground?
    public let backgroundImageCache: NSImage?
    public let shadows: [ScreenshotShadow]
    public let crop: CropRect?
    public let resolution: ScreenshotResolution
    public let positionScale: CGFloat
    public let positionOffsetX: CGFloat
    public let positionOffsetY: CGFloat
    public let canvasPadding: CGFloat
    public let nativeScreenSize: NSSize?

    public init(
        os: TargetOS,
        bezelImage: NSImage,
        scale: CGFloat,
        verticalOffset: CGFloat,
        horizontalOffset: CGFloat,
        cornerRadius: CGFloat,
        screenshotOnTop: Bool,
        scaleUpToFill: Bool = true,
        orientation: ScreenOrientation? = nil,
        background: ScreenshotBackground? = nil,
        backgroundImageCache: NSImage? = nil,
        shadows: [ScreenshotShadow] = [],
        crop: CropRect? = nil,
        resolution: ScreenshotResolution = .full,
        positionScale: CGFloat = 1.0,
        positionOffsetX: CGFloat = 0.0,
        positionOffsetY: CGFloat = 0.0,
        canvasPadding: CGFloat = 0.0,
        nativeScreenSize: NSSize? = nil
    ) {
        self.os = os
        self.bezelImage = bezelImage
        self.scale = scale
        self.verticalOffset = verticalOffset
        self.horizontalOffset = horizontalOffset
        self.cornerRadius = cornerRadius
        self.screenshotOnTop = screenshotOnTop
        self.scaleUpToFill = scaleUpToFill
        self.orientation = orientation
        self.background = background
        self.backgroundImageCache = backgroundImageCache
        self.shadows = shadows
        self.crop = crop
        self.resolution = resolution
        self.positionScale = positionScale
        self.positionOffsetX = positionOffsetX
        self.positionOffsetY = positionOffsetY
        self.canvasPadding = canvasPadding
        self.nativeScreenSize = nativeScreenSize
    }

    /// Backward-compat convenience: wraps a hex string into `.solid`.
    public init(
        os: TargetOS,
        bezelImage: NSImage,
        scale: CGFloat,
        verticalOffset: CGFloat,
        horizontalOffset: CGFloat,
        cornerRadius: CGFloat,
        screenshotOnTop: Bool,
        orientation: ScreenOrientation? = nil,
        backgroundHex: String?,
        crop: CropRect? = nil,
        resolution: ScreenshotResolution = .full
    ) {
        self.os = os
        self.bezelImage = bezelImage
        self.scale = scale
        self.verticalOffset = verticalOffset
        self.horizontalOffset = horizontalOffset
        self.cornerRadius = cornerRadius
        self.screenshotOnTop = screenshotOnTop
        self.scaleUpToFill = true
        self.orientation = orientation
        self.background = backgroundHex.map { .solid(hex: $0) }
        self.backgroundImageCache = nil
        self.shadows = []
        self.crop = crop
        self.resolution = resolution
        self.positionScale = 1.0
        self.positionOffsetX = 0.0
        self.positionOffsetY = 0.0
        self.canvasPadding = 0.0
        self.nativeScreenSize = nil
    }
}

/// Runs the full bezel pipeline with consistent pixel-based coordinate system.
///
/// Step 1: Compose device (screenshot + bezel) at bezel's native pixel resolution.
/// Step 2: Place composition on resolution canvas (scale-to-fit).
/// Step 3: Apply shadows relative to the fitted composition size.
/// Step 4: Apply background behind everything.
/// Step 5: Crop if needed.
public nonisolated func applyBezelPipeline(image: NSImage, params: BezelPipelineParams) -> NSImage {
    // Step 1: Compose device
    guard !Task.isCancelled else { return image }

    let prepared = prepareScreenshot(image: image, os: params.os)

    var masked = prepared
    if params.cornerRadius > 0 {
        let prepSize = prepared.size
        let cornerPx = params.cornerRadius * min(prepSize.width, prepSize.height)
        masked = maskScreenshot(image: prepared, cornerRadius: cornerPx)
    }

    let scaled = scaleToBezel(image: masked, factor: params.scale)

    guard !Task.isCancelled else { return image }

    // Resolution-aware optimization: if the bezel is much larger than the output
    // canvas, pre-scale it to avoid compositing at unnecessarily high resolution.
    let outputSize = params.resolution.size
    let bezelSize = pixelSize(of: params.bezelImage)
    let effectiveBezel: NSImage
    if outputSize.width > 0, outputSize.height > 0,
       bezelSize.width > outputSize.width * 1.5 || bezelSize.height > outputSize.height * 1.5 {
        let downscale = min(outputSize.width / bezelSize.width, outputSize.height / bezelSize.height) * 1.2
        let targetSize = NSSize(width: bezelSize.width * downscale, height: bezelSize.height * downscale)
        effectiveBezel = NSImage(size: targetSize, flipped: false) { _ in
            params.bezelImage.draw(
                in: NSRect(origin: .zero, size: targetSize),
                from: NSRect(origin: .zero, size: params.bezelImage.size),
                operation: .copy,
                fraction: 1.0
            )
            return true
        }
    } else {
        effectiveBezel = params.bezelImage
    }

    let bezeled = placeBezel(
        image: scaled,
        bezel: effectiveBezel,
        verticalOffset: params.verticalOffset,
        horizontalOffset: params.horizontalOffset,
        screenshotOnTop: params.screenshotOnTop,
        scaleUpToFill: params.scaleUpToFill,
        nativeScreenSize: params.nativeScreenSize
    )

    var composition = bezeled
    if let orientation = params.orientation {
        composition = applyOrientation(image: composition, orientation: orientation)
    }

    // Step 2: Place on resolution canvas
    // Use composition.size (not pixelSize) — intermediate images created via drawing handlers
    // already have .size == pixel dimensions. pixelSize would return 2x on Retina.
    let canvasSize = params.resolution.size
    let compSize = composition.size

    guard compSize.width > 0, compSize.height > 0 else { return composition }

    let padding = params.canvasPadding
    let fitScale = min(
        canvasSize.width / compSize.width,
        canvasSize.height / compSize.height
    ) * (1.0 - padding * 2)

    let drawW = compSize.width * fitScale * params.positionScale
    let drawH = compSize.height * fitScale * params.positionScale
    let maxTravelX = canvasSize.width / 2
    let maxTravelY = canvasSize.height / 2
    let drawX = (canvasSize.width - drawW) / 2 + params.positionOffsetX * maxTravelX
    let drawY = (canvasSize.height - drawH) / 2 - params.positionOffsetY * maxTravelY

    let canvas = NSImage(size: canvasSize, flipped: false) { _ in
        if let context = NSGraphicsContext.current {
            context.imageInterpolation = .high
        }
        composition.draw(
            in: NSRect(x: drawX, y: drawY, width: drawW, height: drawH),
            from: NSRect(origin: .zero, size: compSize),
            operation: .sourceOver,
            fraction: 1.0
        )
        return true
    }

    guard !Task.isCancelled else { return image }

    // Step 3: Apply shadows (on canvas, relative to composition rect)
    let compositionCenter = NSPoint(x: drawX + drawW / 2, y: drawY + drawH / 2)
    let compositionSize = NSSize(width: drawW, height: drawH)
    var result = applyShadows(
        image: canvas,
        shadows: params.shadows,
        compositionSize: compositionSize,
        compositionCenter: compositionCenter
    )

    // Step 4: Background (behind)
    result = addBackground(
        image: result,
        background: params.background,
        backgroundImageCache: params.backgroundImageCache
    )

    // Step 5: Crop
    if let crop = params.crop {
        result = cropImage(image: result, crop: crop)
    }

    return result
}

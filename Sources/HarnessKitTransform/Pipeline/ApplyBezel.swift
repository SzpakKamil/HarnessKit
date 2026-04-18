import Foundation
import HarnessKitScreenshots

/// Parameters for the bezel pipeline — composes a screenshot inside a device bezel.
///
/// - Important: Instances must be created and consumed on the same
///   thread/task. Do not share across concurrent contexts after creation.
public struct BezelPipelineParams: @unchecked Sendable {
    public let os: TargetOS
    public let bezelImage: PlatformImage
    public let scale: CGFloat
    public let verticalOffset: CGFloat
    public let horizontalOffset: CGFloat
    public let cornerRadius: CGFloat
    public let screenshotOnTop: Bool
    public let scaleUpToFill: Bool
    public let orientation: ScreenOrientation?
    public let nativeScreenSize: CGSize?

    public init(
        os: TargetOS,
        bezelImage: PlatformImage,
        scale: CGFloat,
        verticalOffset: CGFloat,
        horizontalOffset: CGFloat,
        cornerRadius: CGFloat,
        screenshotOnTop: Bool,
        scaleUpToFill: Bool = true,
        orientation: ScreenOrientation? = nil,
        nativeScreenSize: CGSize? = nil
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
        self.nativeScreenSize = nativeScreenSize
    }
}

/// Composes a screenshot inside a device bezel and returns the tight device image.
///
/// The output is the device composition at native bezel resolution with no
/// surrounding canvas, background, shadows, or crop. Use `renderDeviceOnCanvas`
/// or `renderCanvas` to place the result on a sized canvas.
nonisolated func applyBezelPipeline(image: PlatformImage, params: BezelPipelineParams) -> PlatformImage {
    autoreleasepool {
        guard !Task.isCancelled else { return image }

        // iOS/iPadOS L→L fast path. The current (non-optimized) sequence
        // rotates the screenshot -π/2 in `normalizeToPortrait`, composes
        // against the portrait bezel, then rotates the whole composition
        // +π/2 in `applyOrientation`. The two screenshot rotations cancel;
        // we can compose directly in landscape by pre-rotating the bezel
        // (one bitmap instead of two) and remapping the offset vector.
        let inputSize = imageSize(image)
        let inputIsLandscape = inputSize.width > inputSize.height
        let composeInLandscape = (params.os == .iOS || params.os == .iPadOS)
            && params.orientation == .landscape
            && inputIsLandscape

        let prepared: PlatformImage
        let composingBezel: PlatformImage
        let vOffset: CGFloat
        let hOffset: CGFloat

        if composeInLandscape {
            prepared = normalizeOrientation(image)
            composingBezel = applyOrientation(image: params.bezelImage, orientation: .landscape)
            // +π/2 CCW rotates the portrait shift vector (h, v) to (-v, h).
            hOffset = -params.verticalOffset
            vOffset = params.horizontalOffset
        } else {
            prepared = normalizeToPortrait(image: image, os: params.os)
            composingBezel = params.bezelImage
            hOffset = params.horizontalOffset
            vOffset = params.verticalOffset
        }

        var masked = prepared
        if params.cornerRadius > 0 {
            let prepSize = prepared.size
            let cornerPx = params.cornerRadius * min(prepSize.width, prepSize.height)
            masked = maskScreenshot(image: prepared, cornerRadius: cornerPx)
        }

        let scaled = scaleToBezel(image: masked, factor: params.scale)

        guard !Task.isCancelled else { return image }

        let bezeled = placeBezel(
            image: scaled,
            bezel: composingBezel,
            verticalOffset: vOffset,
            horizontalOffset: hOffset,
            screenshotOnTop: params.screenshotOnTop,
            scaleUpToFill: params.scaleUpToFill,
            nativeScreenSize: params.nativeScreenSize
        )

        var composition = bezeled
        if !composeInLandscape, let orientation = params.orientation {
            composition = applyOrientation(image: composition, orientation: orientation)
        }

        return composition
    }
}

// MARK: - Single-device canvas rendering

/// Places a device image on a canvas with background, shadows, and optional crop.
///
/// This is the standard way to produce a final screenshot image from a tight
/// device composition returned by `applyBezelPipeline`.
nonisolated func renderDeviceOnCanvas(
    deviceImage: PlatformImage,
    canvasSize: CGSize,
    background: ScreenshotBackground? = nil,
    backgroundImageCache: PlatformImage? = nil,
    shadows: [ScreenshotShadow] = [],
    crop: CropRect? = nil,
    positionScale: CGFloat = 1.0,
    positionOffsetX: CGFloat = 0.0,
    positionOffsetY: CGFloat = 0.0,
    canvasPadding: CGFloat = 0.0
) -> PlatformImage {
    autoreleasepool {
        let devSize = deviceImage.size
        guard devSize.width > 0, devSize.height > 0, canvasSize.width > 0, canvasSize.height > 0 else {
            return deviceImage
        }

        // Compute the frame for the device on the canvas (normalized 0-1)
        let fitScale = min(canvasSize.width / devSize.width, canvasSize.height / devSize.height)
            * (1.0 - canvasPadding * 2)

        let drawW = devSize.width * fitScale * positionScale
        let drawH = devSize.height * fitScale * positionScale

        let frameW = drawW / canvasSize.width
        let frameH = drawH / canvasSize.height
        let frameCX = 0.5 + (positionOffsetX * 0.5) * (canvasSize.width / canvasSize.width)
        let frameCY = 0.5 + (positionOffsetY * 0.5) * (canvasSize.height / canvasSize.height)

        // Convert ScreenshotShadow → CanvasLayerShadow
        let canvasShadows: [CanvasLayerShadow] = shadows.map { shadow in
            switch shadow {
            case .drop(let d):
                return .drop(color: d.color, opacity: d.opacity, blur: d.blur, offsetX: d.offsetX, offsetY: d.offsetY)
            case .shape(let s):
                return .contact(color: s.color, opacity: s.opacity, blur: s.blur,
                                contactWidth: s.width, contactHeight: s.height,
                                contactY: s.y, contactCornerRadius: s.cornerRadius)
            }
        }

        let layerID = UUID()
        let layer = CanvasLayer(
            id: layerID,
            name: "Device",
            content: .device(CanvasDeviceConfig(platform: "", deviceID: "")),
            frame: CanvasLayerFrame(x: frameCX, y: frameCY, width: frameW, height: frameH),
            shadows: canvasShadows
        )

        let composition = CanvasComposition(
            width: Int(canvasSize.width),
            height: Int(canvasSize.height),
            background: background,
            layers: [layer],
            crop: crop
        )

        return renderCanvas(composition, deviceImages: [layerID: deviceImage], backgroundImageCache: backgroundImageCache)
    }
}

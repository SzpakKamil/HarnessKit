import Foundation
import CoreGraphics

public struct CanvasLayerFrame: Codable, Hashable, Sendable {
    /// Horizontal center position as fraction of canvas width.
    public var x: Double

    /// Vertical center position as fraction of canvas height.
    public var y: Double

    /// Width as fraction of canvas width (used when `preserveSize` is false).
    public var width: Double

    /// Height as fraction of canvas height (used when `preserveSize` is false).
    public var height: Double

    /// Rotation in degrees (clockwise).
    public var rotation: Double

    /// When true, the layer uses `pixelWidth`/`pixelHeight` for absolute pixel sizing
    /// instead of the normalized `width`/`height` fractions.
    public var preserveSize: Bool

    /// Absolute width in pixels (used when `preserveSize` is true).
    public var pixelWidth: Double

    /// Absolute height in pixels (used when `preserveSize` is true).
    public var pixelHeight: Double

    public init(
        x: Double = 0.5,
        y: Double = 0.5,
        width: Double = 1.0,
        height: Double = 1.0,
        rotation: Double = 0,
        preserveSize: Bool = false,
        pixelWidth: Double = 0,
        pixelHeight: Double = 0
    ) {
        self.x = x
        self.y = y
        self.width = width
        self.height = height
        self.rotation = rotation
        self.preserveSize = preserveSize
        self.pixelWidth = pixelWidth
        self.pixelHeight = pixelHeight
    }

    /// Converts to a pixel rect for a given canvas size. Both platforms
    /// render into a Y-up CGContext (origin at bottom-left), so callers
    /// pass `y` as bottom-up normalized [0, 1] and `y * canvasHeight`
    /// maps directly. The iOS render context is flipped to Y-up inside
    /// `createImage`; see `PlatformImage.swift`.
    public func pixelRect(in canvasSize: CGSize) -> CGRect {
        let w: CGFloat
        let h: CGFloat
        if preserveSize, pixelWidth > 0, pixelHeight > 0 {
            w = CGFloat(pixelWidth)
            h = CGFloat(pixelHeight)
        } else {
            w = CGFloat(width) * canvasSize.width
            h = CGFloat(height) * canvasSize.height
        }
        let cx = CGFloat(x) * canvasSize.width
        let cy = CGFloat(y) * canvasSize.height
        return CGRect(x: cx - w / 2, y: cy - h / 2, width: w, height: h)
    }

    /// The center point in pixels for a given canvas size.
    public func pixelCenter(in canvasSize: CGSize) -> CGPoint {
        CGPoint(x: CGFloat(x) * canvasSize.width, y: CGFloat(y) * canvasSize.height)
    }
}

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

    /// Converts to a pixel rect for a given canvas size.
    /// On macOS the rendering context is bottom-up (y=0 at bottom),
    /// so `y * canvasHeight` maps correctly. On iOS the context is
    /// top-down (y=0 at top) — the `y` value (which callers encode as
    /// bottom-up) must be flipped so layers land at the visual position
    /// the caller intended.
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
        #if canImport(AppKit)
        let cy = CGFloat(y) * canvasSize.height
        #else
        let cy = canvasSize.height - CGFloat(y) * canvasSize.height
        #endif
        return CGRect(x: cx - w / 2, y: cy - h / 2, width: w, height: h)
    }

    /// The center point in pixels for a given canvas size.
    public func pixelCenter(in canvasSize: CGSize) -> CGPoint {
        #if canImport(AppKit)
        CGPoint(x: CGFloat(x) * canvasSize.width, y: CGFloat(y) * canvasSize.height)
        #else
        CGPoint(x: CGFloat(x) * canvasSize.width, y: canvasSize.height - CGFloat(y) * canvasSize.height)
        #endif
    }
}

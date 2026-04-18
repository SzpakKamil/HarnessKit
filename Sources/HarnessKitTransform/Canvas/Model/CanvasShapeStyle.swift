import Foundation

public enum CanvasShapePath: Codable, Hashable, Sendable {
    /// Rectangle with uniform corner radius.
    case rectangle(cornerRadius: Double)
    /// Ellipse inscribed in the layer frame.
    case ellipse
    /// Rounded rectangle with individual corner radii.
    case roundedRectangle(
        topLeft: Double,
        topRight: Double,
        bottomLeft: Double,
        bottomRight: Double
    )
    /// Line segment within the layer frame.
    /// Coordinates are fractions of the frame (0,0 = origin, 1,1 = opposite corner).
    case line(startX: Double, startY: Double, endX: Double, endY: Double)
    /// Custom SVG, embedded as a UTF-8 string in the document.
    /// Rendered via `NSImage(data:)` on macOS — no third-party dependency needed.
    case customSVG(svgString: String)
}

/// Fill style for a canvas shape — solid color, gradient, or image.
public enum CanvasShapeFill: Codable, Hashable, Sendable {
    /// Uniform solid color fill.
    case solid(hex: String, opacity: Double)
    /// Linear gradient between two colors at a given angle (degrees).
    case linearGradient(startHex: String, endHex: String, angle: Double, opacity: Double)
    /// Radial gradient from center color to edge color.
    case radialGradient(centerHex: String, edgeHex: String, opacity: Double)
    /// Image fill clipped to the shape. Scale 1.0 = aspect-fill.
    case image(path: String, scale: Double, offsetX: Double, offsetY: Double)
}

public struct CanvasShapeStyle: Codable, Hashable, Sendable {
    /// The shape geometry.
    public var path: CanvasShapePath
    /// Fill style. `nil` = no fill.
    public var fill: CanvasShapeFill?
    /// Stroke color as hex string. `nil` = no stroke.
    public var strokeColor: String?
    /// Stroke width in points.
    public var strokeWidth: Double
    /// Stroke opacity 0–1.
    public var strokeOpacity: Double

    public init(
        path: CanvasShapePath = .rectangle(cornerRadius: 0),
        fill: CanvasShapeFill? = .solid(hex: "000000", opacity: 1.0),
        strokeColor: String? = nil,
        strokeWidth: Double = 1.0,
        strokeOpacity: Double = 1.0
    ) {
        self.path = path
        self.fill = fill
        self.strokeColor = strokeColor
        self.strokeWidth = strokeWidth
        self.strokeOpacity = strokeOpacity
    }

    /// Convenience: solid fill color hex, or nil if no fill / non-solid fill.
    public var fillColor: String? {
        if case .solid(let hex, _) = fill { return hex }
        return nil
    }

    /// Convenience: fill opacity for solid fills.
    public var fillOpacity: Double {
        if case .solid(_, let opacity) = fill { return opacity }
        return 1.0
    }
}

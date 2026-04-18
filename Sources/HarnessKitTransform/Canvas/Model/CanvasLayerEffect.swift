import Foundation

public enum CanvasLayerEffect: Codable, Hashable, Sendable {
    /// Gaussian blur applied to the entire layer.
    case blur(radius: Double)

    /// Progressive (gradient) blur — sharp at one edge, blurred at the other.
    case progressiveBlur(
        radius: Double,
        direction: ProgressiveBlurDirection,
        startPoint: Double,
        endPoint: Double
    )

    /// Progressive opacity fade — opaque at one edge, transparent at the other.
    case progressiveFade(
        direction: ProgressiveBlurDirection,
        startPoint: Double,
        endPoint: Double
    )

    /// Rounded corner clipping on the layer's rendered content.
    case cornerRadius(radius: Double)

    /// Color overlay blended on top of the layer.
    case colorOverlay(hex: String, opacity: Double)

    /// Border/stroke around the layer bounds.
    case border(hex: String, width: Double, cornerRadius: Double)
}

public enum ProgressiveBlurDirection: String, Codable, Hashable, Sendable {
    case topToBottom
    case bottomToTop
    case leftToRight
    case rightToLeft
}

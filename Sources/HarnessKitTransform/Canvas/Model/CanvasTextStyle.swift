import Foundation

/// How a text layer's size is determined at layout and render time.
public enum CanvasTextExpansion: String, Codable, Hashable, Sendable {
    /// Both width and height are measured from the string + style. The
    /// layer auto-sizes to exactly fit the text; any authored size is
    /// ignored. Default for new text layers.
    case intrinsic
    /// Width is authored; height is measured after the text layout wraps
    /// at that width. Use to author "text must be 300pt wide, growing
    /// downward as content is added".
    case fixedWidthGrowHeight
    /// Height is authored; width is measured (typically one line of text
    /// that grows sideways until it hits content boundaries).
    case fixedHeightGrowWidth
    /// Both dimensions are authored. Text that overflows the frame
    /// clips or overflows depending on renderer options.
    case fixed
}

public struct CanvasTextStyle: Codable, Hashable, Sendable {
    /// Font family name (e.g. "SF Pro", "Helvetica Neue"). Falls back to system font.
    public var fontFamily: String
    /// Font size in points.
    public var fontSize: Double
    /// Font weight (100-900). Maps to NSFont.Weight values.
    /// 100=ultraLight, 200=thin, 300=light, 400=regular, 500=medium,
    /// 600=semibold, 700=bold, 800=heavy, 900=black.
    public var fontWeight: Int
    /// Whether the font is italic.
    public var isItalic: Bool
    /// Text color as hex string.
    public var color: String
    /// Horizontal text alignment within the layer frame.
    public var alignment: CanvasTextAlignment
    /// Vertical text alignment within the layer frame. Only has a
    /// visible effect when the frame's authored height exceeds the
    /// text's measured height (i.e. `.fixed` and `.fixedHeightGrowWidth`
    /// with slack — in `.intrinsic` and `.fixedWidthGrowHeight` the
    /// frame's height IS the measured height, so there's no vertical
    /// space to redistribute). Defaults to `.top` for back-compat with
    /// documents saved before this field existed.
    public var verticalAlignment: CanvasTextVerticalAlignment
    /// Line spacing multiplier (1.0 = default line height).
    public var lineSpacing: Double
    /// Letter spacing (tracking) in points. 0 = default.
    public var letterSpacing: Double
    /// Optional text shadow.
    public var shadow: CanvasTextShadow?
    /// How the layer's size is determined at layout/render time. See
    /// `CanvasTextExpansion`. Defaults to `.intrinsic` (auto-fit).
    public var expansion: CanvasTextExpansion

    public init(
        fontFamily: String = "SF Pro",
        fontSize: Double = 48,
        fontWeight: Int = 400,
        isItalic: Bool = false,
        color: String = "000000",
        alignment: CanvasTextAlignment = .center,
        verticalAlignment: CanvasTextVerticalAlignment = .top,
        lineSpacing: Double = 1.0,
        letterSpacing: Double = 0,
        shadow: CanvasTextShadow? = nil,
        expansion: CanvasTextExpansion = .intrinsic
    ) {
        self.fontFamily = fontFamily
        self.fontSize = fontSize
        self.fontWeight = fontWeight
        self.isItalic = isItalic
        self.color = color
        self.alignment = alignment
        self.verticalAlignment = verticalAlignment
        self.lineSpacing = lineSpacing
        self.letterSpacing = letterSpacing
        self.shadow = shadow
        self.expansion = expansion
    }

    // Custom Codable so documents saved before `expansion` /
    // `verticalAlignment` existed still decode cleanly — the missing
    // fields fall back to `.intrinsic` and `.top` respectively.
    private enum CodingKeys: String, CodingKey {
        case fontFamily, fontSize, fontWeight, isItalic, color, alignment,
             verticalAlignment, lineSpacing, letterSpacing, shadow, expansion
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.fontFamily = try c.decode(String.self, forKey: .fontFamily)
        self.fontSize = try c.decode(Double.self, forKey: .fontSize)
        self.fontWeight = try c.decode(Int.self, forKey: .fontWeight)
        self.isItalic = try c.decode(Bool.self, forKey: .isItalic)
        self.color = try c.decode(String.self, forKey: .color)
        self.alignment = try c.decode(CanvasTextAlignment.self, forKey: .alignment)
        self.verticalAlignment = try c.decodeIfPresent(CanvasTextVerticalAlignment.self, forKey: .verticalAlignment) ?? .top
        self.lineSpacing = try c.decode(Double.self, forKey: .lineSpacing)
        self.letterSpacing = try c.decode(Double.self, forKey: .letterSpacing)
        self.shadow = try c.decodeIfPresent(CanvasTextShadow.self, forKey: .shadow)
        self.expansion = try c.decodeIfPresent(CanvasTextExpansion.self, forKey: .expansion) ?? .intrinsic
    }

    public func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(fontFamily, forKey: .fontFamily)
        try c.encode(fontSize, forKey: .fontSize)
        try c.encode(fontWeight, forKey: .fontWeight)
        try c.encode(isItalic, forKey: .isItalic)
        try c.encode(color, forKey: .color)
        try c.encode(alignment, forKey: .alignment)
        try c.encode(verticalAlignment, forKey: .verticalAlignment)
        try c.encode(lineSpacing, forKey: .lineSpacing)
        try c.encode(letterSpacing, forKey: .letterSpacing)
        try c.encodeIfPresent(shadow, forKey: .shadow)
        try c.encode(expansion, forKey: .expansion)
    }
}

public enum CanvasTextAlignment: String, Codable, Hashable, Sendable {
    case left, center, right
}

public enum CanvasTextVerticalAlignment: String, Codable, Hashable, Sendable {
    case top, center, bottom
}

public struct CanvasTextShadow: Codable, Hashable, Sendable {
    /// Shadow color as hex string.
    public var color: String
    /// Shadow opacity 0–1.
    public var opacity: Double
    /// Blur radius in points.
    public var blur: Double
    /// Horizontal offset in points.
    public var offsetX: Double
    /// Vertical offset in points.
    public var offsetY: Double

    public init(
        color: String = "000000",
        opacity: Double = 0.5,
        blur: Double = 4,
        offsetX: Double = 0,
        offsetY: Double = 2
    ) {
        self.color = color
        self.opacity = opacity
        self.blur = blur
        self.offsetX = offsetX
        self.offsetY = offsetY
    }
}

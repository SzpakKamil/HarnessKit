import Foundation

/// What a canvas layer contains.
public enum CanvasLayerContent: Hashable, Sendable {
    /// A device bezel composition. The image is NOT serialized — only the config
    /// is stored. The renderer re-renders from config on load using `applyBezelPipeline`.
    case device(CanvasDeviceConfig)

    /// Text drawn directly on the canvas with full typography control.
    case text(String, CanvasTextStyle)

    /// A vector shape drawn on the canvas.
    case shape(CanvasShapeStyle)

    /// A raster image loaded from a file path with positioning control.
    case image(path: String, scale: Double, offsetX: Double, offsetY: Double, contentMode: CanvasImageContentMode)
}

/// How an image layer fits its bytes inside the layer's authored frame.
public enum CanvasImageContentMode: String, Codable, Hashable, Sendable {
    /// Image is scaled to fit entirely inside the layer frame, preserving
    /// aspect ratio. Empty space remains on the unmatched axis.
    case fit
    /// Image is scaled to fill the layer frame, preserving aspect ratio.
    /// Overflowing pixels are cropped to the frame rect.
    case fill
}

// MARK: - Codable

extension CanvasLayerContent: Codable {
    // Custom Codable with a `case` discriminator + named per-case payload
    // fields. Replaces the auto-synthesized form so that adding new
    // associated values to a single case (like `contentMode` on `.image`)
    // can grow with `decodeIfPresent` defaults instead of breaking the
    // wire format. Mirrors the precedent in `CanvasTextStyle.swift`.
    private enum CodingKeys: String, CodingKey {
        case type
        // .device
        case device
        // .text
        case text, style
        // .shape
        case shape
        // .image
        case path, scale, offsetX, offsetY, contentMode
    }

    private enum Kind: String, Codable {
        case device, text, shape, image
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        let kind = try c.decode(Kind.self, forKey: .type)
        switch kind {
        case .device:
            let config = try c.decode(CanvasDeviceConfig.self, forKey: .device)
            self = .device(config)
        case .text:
            let string = try c.decode(String.self, forKey: .text)
            let style = try c.decode(CanvasTextStyle.self, forKey: .style)
            self = .text(string, style)
        case .shape:
            let style = try c.decode(CanvasShapeStyle.self, forKey: .shape)
            self = .shape(style)
        case .image:
            let path = try c.decode(String.self, forKey: .path)
            let scale = try c.decode(Double.self, forKey: .scale)
            let offsetX = try c.decode(Double.self, forKey: .offsetX)
            let offsetY = try c.decode(Double.self, forKey: .offsetY)
            let contentMode = try c.decodeIfPresent(CanvasImageContentMode.self, forKey: .contentMode) ?? .fit
            self = .image(path: path, scale: scale, offsetX: offsetX, offsetY: offsetY, contentMode: contentMode)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .device(let config):
            try c.encode(Kind.device, forKey: .type)
            try c.encode(config, forKey: .device)
        case .text(let string, let style):
            try c.encode(Kind.text, forKey: .type)
            try c.encode(string, forKey: .text)
            try c.encode(style, forKey: .style)
        case .shape(let style):
            try c.encode(Kind.shape, forKey: .type)
            try c.encode(style, forKey: .shape)
        case .image(let path, let scale, let offsetX, let offsetY, let contentMode):
            try c.encode(Kind.image, forKey: .type)
            try c.encode(path, forKey: .path)
            try c.encode(scale, forKey: .scale)
            try c.encode(offsetX, forKey: .offsetX)
            try c.encode(offsetY, forKey: .offsetY)
            try c.encode(contentMode, forKey: .contentMode)
        }
    }
}

/// Serializable configuration needed to re-render a device layer.
/// Replaces storing a non-serializable `NSImage` — the renderer uses this
/// config to call `applyBezelPipeline` and produce the device image on demand.
public struct CanvasDeviceConfig: Codable, Hashable, Sendable {
    /// Platform identifier (e.g. "iOS", "macOS", "watchOS").
    public var platform: String
    /// Device model identifier (e.g. "iPhone17", "MacbookPro16M4").
    public var deviceID: String
    /// Bezel color variant (e.g. "Black", "Silver").
    public var color: String
    /// Watch band name (watchOS only, empty for other platforms).
    public var band: String
    /// OS major version string (e.g. "26").
    public var osMajor: String
    /// macOS wallpaper variant (e.g. "Default", "Custom").
    public var wallpaper: String
    /// Color scheme: "light" or "dark".
    public var appearance: String
    /// Scale factor for the screenshot within the bezel frame.
    public var bezelScale: Double
    /// Vertical offset of the screenshot within the bezel.
    public var verticalOffset: Double
    /// Horizontal offset of the screenshot within the bezel.
    public var horizontalOffset: Double
    /// Corner radius for masking the screenshot (fraction of short side).
    public var cornerRadius: Double
    /// Native screen width in pixels.
    public var nativeWidth: Int
    /// Native screen height in pixels.
    public var nativeHeight: Int
    /// Whether macOS screenshot fills the entire screen area.
    public var macFullScreen: Bool
    /// If true, this is a decoration-only device (no screenshot placement).
    public var isDecoration: Bool

    public init(
        platform: String,
        deviceID: String,
        color: String = "",
        band: String = "",
        osMajor: String = "26",
        wallpaper: String = "Default",
        appearance: String = "light",
        bezelScale: Double = 0.9,
        verticalOffset: Double = 0,
        horizontalOffset: Double = 0,
        cornerRadius: Double = 0,
        nativeWidth: Int = 0,
        nativeHeight: Int = 0,
        macFullScreen: Bool = true,
        isDecoration: Bool = false
    ) {
        self.platform = platform
        self.deviceID = deviceID
        self.color = color
        self.band = band
        self.osMajor = osMajor
        self.wallpaper = wallpaper
        self.appearance = appearance
        self.bezelScale = bezelScale
        self.verticalOffset = verticalOffset
        self.horizontalOffset = horizontalOffset
        self.cornerRadius = cornerRadius
        self.nativeWidth = nativeWidth
        self.nativeHeight = nativeHeight
        self.macFullScreen = macFullScreen
        self.isDecoration = isDecoration
    }
}

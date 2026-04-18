import Foundation

public struct CanvasLayerShadow: Codable, Hashable, Sendable {
    public enum ShadowType: String, Codable, Hashable, Sendable {
        /// Follows the alpha shape of the layer content (rendered via NSShadow).
        case drop
        /// Independent rounded-rectangle positioned relative to the layer (contact shadow).
        case contact
    }

    /// The type of shadow.
    public var type: ShadowType
    /// Shadow color as hex string (e.g. "000000").
    public var color: String
    /// Opacity 0–1.
    public var opacity: Double
    /// Blur radius as fraction of the layer's rendered short side.
    public var blur: Double

    // -- Drop shadow properties --
    /// Horizontal offset as fraction of layer width (0 = no offset).
    public var offsetX: Double
    /// Vertical offset as fraction of layer height (0 = no offset).
    public var offsetY: Double

    // -- Contact shadow properties --
    /// Width as fraction of layer width.
    public var contactWidth: Double
    /// Height as fraction of layer height.
    public var contactHeight: Double
    /// Vertical position below layer center (fraction of layer height, negative = below).
    public var contactY: Double
    /// Corner radius factor 0–1 (0 = rectangle, 1 = full ellipse).
    public var contactCornerRadius: Double

    public init(
        type: ShadowType,
        color: String = "000000",
        opacity: Double = 0.5,
        blur: Double = 0.02,
        offsetX: Double = 0,
        offsetY: Double = 0,
        contactWidth: Double = 0,
        contactHeight: Double = 0,
        contactY: Double = 0,
        contactCornerRadius: Double = 0
    ) {
        self.type = type
        self.color = color
        self.opacity = opacity
        self.blur = blur
        self.offsetX = offsetX
        self.offsetY = offsetY
        self.contactWidth = contactWidth
        self.contactHeight = contactHeight
        self.contactY = contactY
        self.contactCornerRadius = contactCornerRadius
    }

    /// Creates a drop shadow with typical defaults.
    public static func drop(
        color: String = "000000",
        opacity: Double = 0.5,
        blur: Double = 0.02,
        offsetX: Double = 0,
        offsetY: Double = 0.01
    ) -> CanvasLayerShadow {
        CanvasLayerShadow(
            type: .drop, color: color, opacity: opacity, blur: blur,
            offsetX: offsetX, offsetY: offsetY
        )
    }

    /// Creates a contact shadow (ellipse beneath the device) with typical defaults.
    public static func contact(
        color: String = "000000",
        opacity: Double = 0.3,
        blur: Double = 0.06,
        contactWidth: Double = 1.1,
        contactHeight: Double = 0.025,
        contactY: Double = -1.03,
        contactCornerRadius: Double = 1
    ) -> CanvasLayerShadow {
        CanvasLayerShadow(
            type: .contact, color: color, opacity: opacity, blur: blur,
            contactWidth: contactWidth, contactHeight: contactHeight,
            contactY: contactY, contactCornerRadius: contactCornerRadius
        )
    }
}

import Foundation

public struct CanvasLayer: Hashable, Sendable, Identifiable {
    /// Unique identifier for this layer.
    public var id: UUID
    /// Human-readable name shown in the layers panel.
    public var name: String
    /// What this layer contains (device, text, shape, or image).
    public var content: CanvasLayerContent
    /// Position and size on the canvas (normalized 0-1 fractions).
    public var frame: CanvasLayerFrame
    /// Shadows rendered at canvas level (never clipped by layer bounds).
    public var shadows: [CanvasLayerShadow]
    /// Visual effects applied to the rendered content.
    public var effects: [CanvasLayerEffect]
    /// Layer opacity 0–1.
    public var opacity: Double
    /// Whether the layer is locked (non-interactive in the editor).
    public var isLocked: Bool
    /// Whether the layer is visible in the composition.
    public var isVisible: Bool
    /// Corner radius (in canvas pixels) applied as a rounded-rect clip to
    /// the rendered content. 0 = sharp corners.
    public var cornerRadius: Double
    /// Optional hex background color drawn behind the layer's rendered
    /// content (e.g. `"FF0000"` or `"FF0000CC"` with alpha). Empty = no
    /// background fill. Rounded with `cornerRadius` when non-zero.
    public var backgroundColor: String

    public init(
        id: UUID = UUID(),
        name: String = "Layer",
        content: CanvasLayerContent,
        frame: CanvasLayerFrame = CanvasLayerFrame(),
        shadows: [CanvasLayerShadow] = [],
        effects: [CanvasLayerEffect] = [],
        opacity: Double = 1.0,
        isLocked: Bool = false,
        isVisible: Bool = true,
        cornerRadius: Double = 0,
        backgroundColor: String = ""
    ) {
        self.id = id
        self.name = name
        self.content = content
        self.frame = frame
        self.shadows = shadows
        self.effects = effects
        self.opacity = opacity
        self.isLocked = isLocked
        self.isVisible = isVisible
        self.cornerRadius = cornerRadius
        self.backgroundColor = backgroundColor
    }
}

// MARK: - Codable

extension CanvasLayer: Codable {
    private enum CodingKeys: String, CodingKey {
        case id, name, content, frame, shadows, effects, opacity, isLocked, isVisible
        case cornerRadius, backgroundColor
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id              = try c.decode(UUID.self,                forKey: .id)
        name            = try c.decode(String.self,              forKey: .name)
        content         = try c.decode(CanvasLayerContent.self,  forKey: .content)
        frame           = try c.decode(CanvasLayerFrame.self,    forKey: .frame)
        shadows         = try c.decodeIfPresent([CanvasLayerShadow].self,  forKey: .shadows)  ?? []
        effects         = try c.decodeIfPresent([CanvasLayerEffect].self,  forKey: .effects)  ?? []
        opacity         = try c.decodeIfPresent(Double.self,     forKey: .opacity)         ?? 1.0
        isLocked        = try c.decodeIfPresent(Bool.self,       forKey: .isLocked)        ?? false
        isVisible       = try c.decodeIfPresent(Bool.self,       forKey: .isVisible)       ?? true
        cornerRadius    = try c.decodeIfPresent(Double.self,     forKey: .cornerRadius)    ?? 0
        backgroundColor = try c.decodeIfPresent(String.self,    forKey: .backgroundColor) ?? ""
    }

    public func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id,      forKey: .id)
        try c.encode(name,    forKey: .name)
        try c.encode(content, forKey: .content)
        try c.encode(frame,   forKey: .frame)
        if !shadows.isEmpty   { try c.encode(shadows,  forKey: .shadows)  }
        if !effects.isEmpty   { try c.encode(effects,  forKey: .effects)  }
        if opacity != 1.0     { try c.encode(opacity,  forKey: .opacity)  }
        if isLocked           { try c.encode(isLocked, forKey: .isLocked) }
        if !isVisible         { try c.encode(isVisible, forKey: .isVisible) }
        if cornerRadius    != 0  { try c.encode(cornerRadius,    forKey: .cornerRadius)    }
        if !backgroundColor.isEmpty { try c.encode(backgroundColor, forKey: .backgroundColor) }
    }
}

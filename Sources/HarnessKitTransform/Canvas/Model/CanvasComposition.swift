import Foundation
import CoreGraphics
import HarnessKitScreenshots

public struct CanvasComposition: Codable, Hashable, Sendable {
    /// Canvas width in pixels.
    public var width: Int
    /// Canvas height in pixels.
    public var height: Int
    /// Background fill for the entire canvas.
    public var background: ScreenshotBackground?
    /// Ordered layers (index 0 = bottom, last = top).
    public var layers: [CanvasLayer]
    /// Optional crop applied to the final output.
    public var crop: CropRect?

    /// Canvas dimensions as CGSize.
    public var size: CGSize {
        CGSize(width: CGFloat(width), height: CGFloat(height))
    }

    public init(
        width: Int = 2089,
        height: Int = 1440,
        background: ScreenshotBackground? = nil,
        layers: [CanvasLayer] = [],
        crop: CropRect? = nil
    ) {
        self.width = width
        self.height = height
        self.background = background
        self.layers = layers
        self.crop = crop
    }

    // MARK: - Layer management

    /// Appends a layer at the top of the stack.
    public mutating func addLayer(_ layer: CanvasLayer) {
        layers.append(layer)
    }

    /// Removes a layer by ID.
    public mutating func removeLayer(id: UUID) {
        layers.removeAll { $0.id == id }
    }

    /// Moves a layer from one index to another.
    public mutating func moveLayer(from source: Int, to destination: Int) {
        guard layers.indices.contains(source) else { return }
        let layer = layers.remove(at: source)
        let clampedDest = min(destination, layers.count)
        layers.insert(layer, at: clampedDest)
    }

    /// Returns the layer with the given ID, or nil.
    public func layer(for id: UUID) -> CanvasLayer? {
        layers.first { $0.id == id }
    }

    /// Mutates the layer with the given ID in place.
    public mutating func updateLayer(id: UUID, _ transform: (inout CanvasLayer) -> Void) {
        guard let index = layers.firstIndex(where: { $0.id == id }) else { return }
        transform(&layers[index])
    }
}

import Foundation
import CoreGraphics
import HarnessKitScreenshots

/// Public namespace for canvas rendering.
public enum Canvas {

    /// Renders a `CanvasComposition` into a final image.
    ///
    /// - Parameters:
    ///   - composition: The canvas composition to render.
    ///   - deviceImages: Pre-rendered device images keyed by `CanvasLayer.id`.
    ///     Required for `.device` layers; the renderer does not load device
    ///     bezels itself.
    ///   - imageLayerImages: Pre-decoded `PlatformImage`s for `.image` layers
    ///     keyed by `CanvasLayer.id`. When a layer has no entry, the
    ///     renderer falls back to loading the layer's `path` field from disk.
    ///   - backgroundImage: Pre-decoded background image. When nil and
    ///     `composition.background` is `.image`, the renderer loads from disk.
    public static func render(
        _ composition: CanvasComposition,
        deviceImages: [UUID: PlatformImage] = [:],
        imageLayerImages: [UUID: PlatformImage] = [:],
        backgroundImage: PlatformImage? = nil
    ) -> PlatformImage {
        renderCanvas(
            composition,
            deviceImages: deviceImages,
            imageLayerImages: imageLayerImages,
            backgroundImageCache: backgroundImage
        )
    }
}

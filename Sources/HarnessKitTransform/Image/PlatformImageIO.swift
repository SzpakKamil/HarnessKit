import Foundation
import CoreGraphics

/// Public namespace for platform image I/O — load, save, encode, and
/// metric helpers over `PlatformImage` (NSImage on macOS, UIImage on
/// iOS/iPadOS/visionOS).
public enum PlatformImageIO {

    /// Loads an image from a URL, optionally downsampling to fit within
    /// `maxPixelSize` on its longest edge. When `maxPixelSize` is nil,
    /// loads the full-resolution image.
    public static func load(_ url: URL, maxPixelSize: Int? = nil) -> PlatformImage? {
        platformImage(contentsOf: url, maxPixelSize: maxPixelSize)
    }

    /// Loads an image from a file path with optional downsampling.
    public static func load(contentsOfFile path: String, maxPixelSize: Int? = nil) -> PlatformImage? {
        platformImage(contentsOfFile: path, maxPixelSize: maxPixelSize)
    }

    /// Writes `image` directly to `url` as a PNG via `CGImageDestination`,
    /// avoiding an intermediate `Data` buffer.
    public static func savePNG(_ image: PlatformImage, to url: URL) throws {
        try HarnessKitTransform.savePNG(image: image, to: url)
    }

    /// Encodes the image as PNG data.
    public static func pngData(_ image: PlatformImage) -> Data? {
        HarnessKitTransform.pngData(from: image)
    }

    /// Returns the pixel dimensions of the image (CGImage-backed pixel count).
    public static func pixelSize(of image: PlatformImage) -> CGSize {
        imagePixelSize(image)
    }

    /// Returns the image's `.size` property (points on macOS, pixels on UIKit).
    public static func size(of image: PlatformImage) -> CGSize {
        imageSize(image)
    }

    /// Returns the underlying `CGImage`.
    public static func cgImage(_ image: PlatformImage) -> CGImage? {
        HarnessKitTransform.cgImage(from: image)
    }
}

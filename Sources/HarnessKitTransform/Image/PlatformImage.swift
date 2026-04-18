// Cross-platform abstractions for image creation and drawing.
// macOS uses AppKit (NSImage), iOS/iPadOS/visionOS use UIKit (UIImage).

import Foundation
import CoreGraphics
import CoreImage
import ImageIO
import UniformTypeIdentifiers

#if canImport(AppKit)
import AppKit
public typealias PlatformImage = NSImage
public typealias PlatformColor = NSColor
public typealias PlatformFont = NSFont
public typealias PlatformFontDescriptor = NSFontDescriptor
public typealias PlatformBezierPath = NSBezierPath
#elseif canImport(UIKit)
import UIKit
public typealias PlatformImage = UIImage
public typealias PlatformColor = UIColor
public typealias PlatformFont = UIFont
public typealias PlatformFontDescriptor = UIFontDescriptor
public typealias PlatformBezierPath = UIBezierPath
#endif

// MARK: - Image Creation

/// Creates an image by drawing into a CGContext at 1× pixel density —
/// the returned `PlatformImage`'s pixel dimensions equal the requested
/// `size` in pixels.
///
/// On macOS the prior `NSImage(size:flipped:drawing:)` approach leaked
/// the display's backing scale into every rendered intermediate: a 320-pt
/// canvas on a Retina Mac produced a 640-pixel PNG. Authored-pixel
/// dimensions (`CanvasComposition.width`, `ScreenshotResolution`) would
/// not match the output. This path forces a 1× `CGContext` so
/// `composition.width = 320` produces exactly 320 output pixels on every
/// display.
///
/// The iOS path already forced 1× via `format.scale = 1.0`.
nonisolated func createImage(size: CGSize, flipped: Bool = false, drawing: @Sendable @escaping (CGContext) -> Void) -> PlatformImage {
    #if canImport(AppKit)
    let w = max(1, Int(size.width.rounded()))
    let h = max(1, Int(size.height.rounded()))
    guard let cgCtx = CGContext(
        data: nil,
        width: w,
        height: h,
        bitsPerComponent: 8,
        bytesPerRow: 0,
        space: CGColorSpaceCreateDeviceRGB(),
        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
    ) else {
        return NSImage(size: size)
    }
    // NSAttributedString.draw(in:) and NSImage.draw(in:from:operation:fraction:)
    // both query `NSGraphicsContext.current?.isFlipped` — the explicit
    // `flipped:` in the initializer is what lets text render right-side-up
    // in top-down coords.
    let nsctx = NSGraphicsContext(cgContext: cgCtx, flipped: flipped)
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = nsctx
    if flipped {
        cgCtx.translateBy(x: 0, y: CGFloat(h))
        cgCtx.scaleBy(x: 1, y: -1)
    }
    drawing(cgCtx)
    NSGraphicsContext.restoreGraphicsState()
    guard let cg = cgCtx.makeImage() else {
        return NSImage(size: size)
    }
    // Wrap in NSImage with `rep.size == pixel size` so `image.size`
    // (points) equals pixel dimensions — keeps the 1× contract intact
    // when this image is subsequently drawn into another context.
    let rep = NSBitmapImageRep(cgImage: cg)
    rep.size = NSSize(width: w, height: h)
    let image = NSImage(size: NSSize(width: w, height: h))
    image.addRepresentation(rep)
    return image
    #else
    let format = UIGraphicsImageRendererFormat()
    format.scale = 1.0
    format.opaque = false
    let renderer = UIGraphicsImageRenderer(size: size, format: format)
    return renderer.image { rendererCtx in
        let ctx = rendererCtx.cgContext
        // UIGraphicsImageRenderer provides a top-down context matching
        // UIKit convention. No manual transform needed — text APIs and
        // CGContext drawing both work correctly in this orientation.
        // The `flipped` parameter is handled by the macOS path only
        // (NSImage flipped:); on iOS the context is inherently top-down.
        drawing(ctx)
    }
    #endif
}

// MARK: - Image Orientation

/// Returns a `.up`-oriented copy of `image`, allocating only when the
/// input isn't already upright.
///
/// On macOS `NSImage` doesn't track an orientation flag, so this is
/// the identity function. On iOS/iPadOS/tvOS/watchOS/visionOS, a
/// `UIImage` loaded via `UIImage(contentsOfFile:)` preserves EXIF
/// orientation; drawing such an image through `cgImage` yields the
/// pre-rotation bitmap. One-shot normalization at the pipeline entry
/// (`normalizeToPortrait`) lets every downstream `drawImageInContext`
/// assume `.up` and skip a per-call render-into-bitmap dance.
nonisolated func normalizeOrientation(_ image: PlatformImage) -> PlatformImage {
    #if canImport(AppKit)
    return image
    #else
    guard image.imageOrientation != .up else { return image }
    let fmt = UIGraphicsImageRendererFormat()
    fmt.scale = 1.0
    return UIGraphicsImageRenderer(size: image.size, format: fmt)
        .image { _ in image.draw(in: CGRect(origin: .zero, size: image.size)) }
    #endif
}

// MARK: - Image Drawing

/// Draws a platform image into the given rect in the current graphics context.
///
/// - Precondition: on UIKit platforms, `image.imageOrientation` must
///   be `.up`. Callers that receive arbitrary `UIImage`s (EXIF-tagged
///   screenshots, etc.) should run them through `normalizeOrientation`
///   first — typically in `normalizeToPortrait`.
nonisolated func drawImageInContext(_ image: PlatformImage, in rect: CGRect, context ctx: CGContext) {
    #if canImport(AppKit)
    NSGraphicsContext.current.map { _ in
        image.draw(in: rect, from: NSRect(origin: .zero, size: image.size),
                   operation: .sourceOver, fraction: 1.0)
    }
    #else
    guard let cgImg = image.cgImage else { return }
    ctx.saveGState()
    ctx.translateBy(x: rect.minX, y: rect.maxY)
    ctx.scaleBy(x: 1, y: -1)
    ctx.draw(cgImg, in: CGRect(origin: .zero, size: rect.size))
    ctx.restoreGState()
    #endif
}

/// Draws a platform image with opacity.
nonisolated func drawImageInContext(_ image: PlatformImage, in rect: CGRect, context ctx: CGContext, opacity: CGFloat) {
    #if canImport(AppKit)
    image.draw(in: rect, from: NSRect(origin: .zero, size: image.size),
               operation: .sourceOver, fraction: opacity)
    #else
    ctx.saveGState()
    ctx.setAlpha(opacity)
    drawImageInContext(image, in: rect, context: ctx)
    ctx.restoreGState()
    #endif
}

// MARK: - CGImage Conversion

/// Gets a CGImage from a platform image.
nonisolated func cgImage(from image: PlatformImage) -> CGImage? {
    #if canImport(AppKit)
    return image.cgImage(forProposedRect: nil, context: nil, hints: nil)
    #else
    return image.cgImage
    #endif
}

/// Creates a platform image from a CGImage.
nonisolated func platformImage(from cgImg: CGImage, size: CGSize) -> PlatformImage {
    #if canImport(AppKit)
    return NSImage(cgImage: cgImg, size: size)
    #else
    return UIImage(cgImage: cgImg)
    #endif
}

/// Loads a platform image from a URL.
nonisolated func platformImage(contentsOf url: URL) -> PlatformImage? {
    #if canImport(AppKit)
    return NSImage(contentsOf: url)
    #else
    guard url.isFileURL else { return nil }
    return UIImage(contentsOfFile: url.path)
    #endif
}

/// Loads a platform image from a file path.
nonisolated func platformImage(contentsOfFile path: String) -> PlatformImage? {
    #if canImport(AppKit)
    return NSImage(contentsOfFile: path)
    #else
    return UIImage(contentsOfFile: path)
    #endif
}

/// Loads a platform image from a URL, optionally downsampling to fit
/// within `maxPixelSize` on its longest edge.
///
/// Uses `CGImageSourceCreateThumbnailAtIndex` with
/// `kCGImageSourceCreateThumbnailFromImageAlways` + `…WithTransform` so
/// EXIF orientation is baked in. When `maxPixelSize == nil`, falls
/// through to the full-resolution loader for identical behavior.
///
/// On macOS the result's `imagePixelSize` matches the underlying
/// `CGImage` pixel count — we wrap via `NSBitmapImageRep` rather than
/// `NSImage(cgImage:size:)` so Retina backing scale does not inflate
/// the reported pixel dimensions (which downstream cache accounting
/// in `BezelImageCache` relies on).
nonisolated func platformImage(contentsOf url: URL, maxPixelSize: Int?) -> PlatformImage? {
    guard let maxPixelSize else {
        return platformImage(contentsOf: url)
    }
    guard let source = CGImageSourceCreateWithURL(url as CFURL, nil) else { return nil }
    let opts: [CFString: Any] = [
        kCGImageSourceThumbnailMaxPixelSize: maxPixelSize,
        kCGImageSourceCreateThumbnailFromImageAlways: true,
        kCGImageSourceCreateThumbnailWithTransform: true,
        kCGImageSourceShouldCacheImmediately: true,
    ]
    guard let cg = CGImageSourceCreateThumbnailAtIndex(source, 0, opts as CFDictionary) else {
        return nil
    }
    #if canImport(AppKit)
    let rep = NSBitmapImageRep(cgImage: cg)
    rep.size = NSSize(width: cg.width, height: cg.height)
    let image = NSImage(size: rep.size)
    image.addRepresentation(rep)
    return image
    #else
    return UIImage(cgImage: cg)
    #endif
}

/// Loads a platform image from a file path with optional downsampling.
nonisolated func platformImage(contentsOfFile path: String, maxPixelSize: Int?) -> PlatformImage? {
    platformImage(contentsOf: URL(fileURLWithPath: path), maxPixelSize: maxPixelSize)
}

// MARK: - Image Metrics

/// Returns the pixel dimensions of a platform image.
nonisolated func imagePixelSize(_ image: PlatformImage) -> CGSize {
    #if canImport(AppKit)
    guard let rep = image.representations.first,
          rep.pixelsWide > 0, rep.pixelsHigh > 0 else { return image.size }
    return CGSize(width: rep.pixelsWide, height: rep.pixelsHigh)
    #else
    guard let cg = image.cgImage else { return image.size }
    return CGSize(width: cg.width, height: cg.height)
    #endif
}

/// Returns the .size property of the image (points, not pixels on macOS).
nonisolated func imageSize(_ image: PlatformImage) -> CGSize {
    image.size
}

// MARK: - PNG Encoding

/// Encodes a platform image as PNG data.
///
/// On macOS, goes through `CGImageDestination` (ImageIO) — the
/// old path allocated an `NSImage.tiffRepresentation` (full-resolution
/// uncompressed bitmap, ~W×H×4 bytes) AND then re-decoded that into
/// an `NSBitmapImageRep` before writing PNG. On a 4K canvas that was
/// ~60 MB of transient bitmap per export, autoreleased on top of the
/// renderer's own accumulation. ImageIO streams straight from the
/// existing `CGImage` into a `CFMutableData`.
nonisolated func pngData(from image: PlatformImage) -> Data? {
    #if canImport(AppKit)
    guard let cg = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
        return nil
    }
    let data = NSMutableData()
    let type: CFString = UTType.png.identifier as CFString
    guard let dest = CGImageDestinationCreateWithData(data, type, 1, nil) else {
        return nil
    }
    CGImageDestinationAddImage(dest, cg, nil)
    guard CGImageDestinationFinalize(dest) else { return nil }
    return data as Data
    #else
    return image.pngData()
    #endif
}

/// Writes `image` directly to `url` as a PNG via ImageIO's
/// `CGImageDestinationCreateWithURL`. Skips the in-memory `Data` buffer
/// `pngData(from:)` allocates — important for batch flows that save
/// many large canvases (≈ 0.5–2 MB compressed PNG per 4K canvas).
/// Cross-platform via the existing `cgImage(from:)` helper.
nonisolated func savePNG(image: PlatformImage, to url: URL) throws {
    guard let cg = cgImage(from: image) else {
        throw NSError(
            domain: "HarnessKitTransform.PlatformImage",
            code: 1,
            userInfo: [NSLocalizedDescriptionKey: "Image could not be converted to CGImage"]
        )
    }
    guard let dest = CGImageDestinationCreateWithURL(
        url as CFURL, UTType.png.identifier as CFString, 1, nil
    ) else {
        throw NSError(
            domain: "HarnessKitTransform.PlatformImage",
            code: 2,
            userInfo: [NSLocalizedDescriptionKey: "Could not create PNG destination at \(url.path)"]
        )
    }
    CGImageDestinationAddImage(dest, cg, nil)
    guard CGImageDestinationFinalize(dest) else {
        throw NSError(
            domain: "HarnessKitTransform.PlatformImage",
            code: 3,
            userInfo: [NSLocalizedDescriptionKey: "PNG destination finalize failed for \(url.path)"]
        )
    }
}

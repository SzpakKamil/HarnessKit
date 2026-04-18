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

/// Creates an image by drawing into a CGContext.
nonisolated func createImage(size: CGSize, flipped: Bool = false, drawing: @Sendable @escaping (CGContext) -> Void) -> PlatformImage {
    #if canImport(AppKit)
    let image = NSImage(size: size, flipped: flipped) { _ in
        guard let ctx = NSGraphicsContext.current?.cgContext else { return false }
        drawing(ctx)
        return true
    }
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
/// (`prepareScreenshot`) lets every downstream `drawImageInContext`
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
///   first — typically in `prepareScreenshot`.
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

// MARK: - Color Helpers

/// Non-alphanumeric characters stripped from hex color strings. Hoisted to
/// module scope so repeated `platformColor(hex:)` calls (dozens per canvas
/// render) don't rebuild the inverted bitmap every time.
private let hexTrimCharacters: CharacterSet = CharacterSet.alphanumerics.inverted

/// Creates a platform color from a hex string and opacity.
nonisolated func platformColor(hex: String, opacity: Double) -> PlatformColor {
    let cleaned = hex.trimmingCharacters(in: hexTrimCharacters)
    var int: UInt64 = 0
    Scanner(string: cleaned).scanHexInt64(&int)
    return PlatformColor(
        red: CGFloat((int >> 16) & 0xFF) / 255.0,
        green: CGFloat((int >> 8) & 0xFF) / 255.0,
        blue: CGFloat(int & 0xFF) / 255.0,
        alpha: CGFloat(opacity)
    )
}

// MARK: - Gradient Helpers

/// Draws a linear gradient between two colors at a given angle.
nonisolated func drawLinearGradient(
    in ctx: CGContext,
    rect: CGRect,
    startColor: PlatformColor,
    endColor: PlatformColor,
    angle: CGFloat
) {
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    guard let gradient = CGGradient(
        colorsSpace: colorSpace,
        colors: [startColor.cgColor, endColor.cgColor] as CFArray,
        locations: [0, 1]
    ) else { return }

    let radians = angle * .pi / 180
    let center = CGPoint(x: rect.midX, y: rect.midY)
    let length = max(rect.width, rect.height)
    let start = CGPoint(x: center.x - cos(radians) * length / 2,
                        y: center.y - sin(radians) * length / 2)
    let end = CGPoint(x: center.x + cos(radians) * length / 2,
                      y: center.y + sin(radians) * length / 2)
    ctx.drawLinearGradient(gradient, start: start, end: end, options: [.drawsBeforeStartLocation, .drawsAfterEndLocation])
}

/// Draws a radial gradient from center to edges.
nonisolated func drawRadialGradient(
    in ctx: CGContext,
    rect: CGRect,
    centerColor: PlatformColor,
    edgeColor: PlatformColor
) {
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    guard let gradient = CGGradient(
        colorsSpace: colorSpace,
        colors: [centerColor.cgColor, edgeColor.cgColor] as CFArray,
        locations: [0, 1]
    ) else { return }

    let center = CGPoint(x: rect.midX, y: rect.midY)
    let radius = max(rect.width, rect.height) / 2
    ctx.drawRadialGradient(gradient, startCenter: center, startRadius: 0,
                           endCenter: center, endRadius: radius, options: [])
}

// MARK: - Shadow Helper

/// Sets a shadow on the given CGContext.
nonisolated func setContextShadow(ctx: CGContext, color: PlatformColor, blur: CGFloat, offset: CGSize) {
    ctx.setShadow(offset: offset, blur: blur, color: color.cgColor)
}

// MARK: - Font Helper

/// Creates a platform font matching the given parameters.
nonisolated func resolveFont(family: String, size: CGFloat, weight: Int, italic: Bool) -> PlatformFont {
    #if canImport(AppKit)
    let nsWeight: NSFont.Weight = switch weight {
    case ..<150: .ultraLight
    case ..<250: .thin
    case ..<350: .light
    case ..<450: .regular
    case ..<550: .medium
    case ..<650: .semibold
    case ..<750: .bold
    case ..<850: .heavy
    default: .black
    }
    let descriptor = NSFontDescriptor(fontAttributes: [
        .family: family,
        .traits: [NSFontDescriptor.TraitKey.weight: nsWeight]
    ])
    let resolved = italic ? descriptor.withSymbolicTraits(.italic) : descriptor
    return NSFont(descriptor: resolved, size: size)
        ?? NSFont.systemFont(ofSize: size, weight: nsWeight)
    #else
    let uiWeight: UIFont.Weight = switch weight {
    case ..<150: .ultraLight
    case ..<250: .thin
    case ..<350: .light
    case ..<450: .regular
    case ..<550: .medium
    case ..<650: .semibold
    case ..<750: .bold
    case ..<850: .heavy
    default: .black
    }
    var descriptor = UIFontDescriptor(fontAttributes: [
        .family: family,
        .traits: [UIFontDescriptor.TraitKey.weight: uiWeight]
    ])
    if italic {
        descriptor = descriptor.withSymbolicTraits(.traitItalic) ?? descriptor
    }
    return UIFont(descriptor: descriptor, size: size)
    #endif
}

// MARK: - BezierPath Helpers

/// Creates a rounded rect bezier path (cross-platform).
nonisolated func makeRoundedRectPath(rect: CGRect, xRadius: CGFloat, yRadius: CGFloat) -> PlatformBezierPath {
    #if canImport(AppKit)
    return NSBezierPath(roundedRect: rect, xRadius: xRadius, yRadius: yRadius)
    #else
    return UIBezierPath(roundedRect: rect, cornerRadius: min(xRadius, yRadius))
    #endif
}

/// Creates an oval bezier path.
nonisolated func makeOvalPath(in rect: CGRect) -> PlatformBezierPath {
    #if canImport(AppKit)
    return NSBezierPath(ovalIn: rect)
    #else
    return UIBezierPath(ovalIn: rect)
    #endif
}

/// Creates a rect bezier path.
nonisolated func makeRectPath(_ rect: CGRect) -> PlatformBezierPath {
    #if canImport(AppKit)
    return NSBezierPath(rect: rect)
    #else
    return UIBezierPath(rect: rect)
    #endif
}

/// Adds a line to a bezier path (cross-platform).
nonisolated func pathAddLine(_ path: PlatformBezierPath, to point: CGPoint) {
    #if canImport(AppKit)
    path.line(to: point)
    #else
    path.addLine(to: point)
    #endif
}

/// Adds an arc to a bezier path.
nonisolated func pathAddArc(_ path: PlatformBezierPath, center: CGPoint, radius: CGFloat, startAngle: CGFloat, endAngle: CGFloat) {
    #if canImport(AppKit)
    path.appendArc(withCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle)
    #else
    path.addArc(withCenter: center, radius: radius, startAngle: startAngle * .pi / 180, endAngle: endAngle * .pi / 180, clockwise: false)
    #endif
}

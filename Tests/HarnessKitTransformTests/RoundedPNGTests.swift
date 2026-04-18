//
//  RoundedPNGTests.swift
//  HarnessKitTransformTests
//
//  Covers §S7.1 — `_roundedPNG` rewritten from the NSImage / TIFF /
//  NSBitmapImageRep / PNG path to a direct CGImageSource → CGContext →
//  CGImageDestination pipeline. The test embeds the OLD implementation
//  as `_legacyRoundedPNG_forComparison` so it can pixel-compare old vs
//  new output on the same input. After this test ages out the old impl
//  inline reference can be deleted.
//
//  macOS-only because `_roundedPNG` is `#if os(macOS)`-gated.
//

#if os(macOS)
import XCTest
import AppKit
import CoreGraphics
import ImageIO
import UniformTypeIdentifiers
@testable import HarnessKitScreenshotTesting

final class RoundedPNGTests: XCTestCase {

    // MARK: - Reference PNG

    /// Builds a `width × height` solid-magenta PNG so the rounded-corner
    /// clip's transparent pixels are easy to detect (alpha goes from 255 in
    /// the kept area to 0 in the clipped corners).
    private func referencePNG(width: Int, height: Int) -> Data {
        let cs = CGColorSpaceCreateDeviceRGB()
        let ctx = CGContext(
            data: nil, width: width, height: height,
            bitsPerComponent: 8, bytesPerRow: 0, space: cs,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        )!
        ctx.setFillColor(red: 1.0, green: 0.0, blue: 1.0, alpha: 1.0)
        ctx.fill(CGRect(x: 0, y: 0, width: width, height: height))
        let cg = ctx.makeImage()!
        let out = NSMutableData()
        let dest = CGImageDestinationCreateWithData(out, UTType.png.identifier as CFString, 1, nil)!
        CGImageDestinationAddImage(dest, cg, nil)
        XCTAssertTrue(CGImageDestinationFinalize(dest))
        return out as Data
    }

    private func decodeBitmap(from data: Data) -> (cg: CGImage, pixels: [UInt8])? {
        guard
            let src = CGImageSourceCreateWithData(data as CFData, nil),
            let cg = CGImageSourceCreateImageAtIndex(src, 0, nil)
        else { return nil }
        let w = cg.width, h = cg.height
        let cs = CGColorSpaceCreateDeviceRGB()
        var bytes = [UInt8](repeating: 0, count: w * h * 4)
        guard let ctx = bytes.withUnsafeMutableBytes({ ptr in
            CGContext(
                data: ptr.baseAddress, width: w, height: h,
                bitsPerComponent: 8, bytesPerRow: w * 4, space: cs,
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
            )
        }) else { return nil }
        ctx.draw(cg, in: CGRect(x: 0, y: 0, width: w, height: h))
        return (cg, bytes)
    }

    // MARK: - Legacy implementation (frozen for comparison)

    /// Bit-for-bit copy of the pre-§S7.1 `_roundedPNG` body. Kept here so the
    /// new implementation can be pixel-diffed against it. Once `git blame`
    /// confirms no behavioral drift, this duplicate can be deleted.
    private func _legacyRoundedPNG_forComparison(
        fromPNG pngData: Data,
        cornerRadius: CGFloat,
        insets: NSEdgeInsets = .init()
    ) -> Data? {
        guard let nsImage = NSImage(data: pngData) else { return nil }
        let size = nsImage.size
        let pixelSize = NSSize(width: size.width, height: size.height)
        let rect = NSRect(origin: .zero, size: pixelSize)
        let insetRect = rect.insetBy(
            dx: insets.left + insets.right > 0 ? insets.left : 0,
            dy: insets.top + insets.bottom > 0 ? insets.top : 0
        )
        let img = NSImage(size: pixelSize, flipped: false) { _ in
            NSGraphicsContext.current?.imageInterpolation = .high
            let path = NSBezierPath(roundedRect: insetRect, xRadius: cornerRadius, yRadius: cornerRadius)
            path.addClip()
            nsImage.draw(in: rect, from: .zero, operation: .sourceOver, fraction: 1.0)
            return true
        }
        guard
            let tiff = img.tiffRepresentation,
            let bitmap = NSBitmapImageRep(data: tiff),
            let png = bitmap.representation(using: .png, properties: [:])
        else { return nil }
        return png
    }

    // MARK: - Tests

    /// New implementation produces a valid, correctly-sized PNG.
    func testNewRoundedPNGDecodesAndPreservesSize() throws {
        let input = referencePNG(width: 200, height: 200)
        let out = try XCTUnwrap(_roundedPNG(fromPNG: input, cornerRadius: 32))
        let decoded = try XCTUnwrap(decodeBitmap(from: out))
        XCTAssertEqual(decoded.cg.width, 200)
        XCTAssertEqual(decoded.cg.height, 200)
    }

    /// Rounded clip actually rounded the corners — the (0,0) pixel of the
    /// output bitmap (top-left corner of the bounding rect) is fully
    /// transparent because the corner-radius arc never touches it. The center
    /// pixel is fully opaque.
    func testCornerIsTransparentCenterIsOpaque() throws {
        let input = referencePNG(width: 200, height: 200)
        let out = try XCTUnwrap(_roundedPNG(fromPNG: input, cornerRadius: 40))
        let decoded = try XCTUnwrap(decodeBitmap(from: out))

        // Bytes are RGBA premultiplied. Sample (1,1) and (199,1) corners +
        // center (100,100). Indexing: row * w*4 + col * 4 + channel.
        let w = decoded.cg.width
        func alpha(x: Int, y: Int) -> UInt8 { decoded.pixels[y * w * 4 + x * 4 + 3] }

        XCTAssertEqual(alpha(x: 1, y: 1), 0,
            "top-left inside-corner pixel must be transparent (clipped)")
        XCTAssertEqual(alpha(x: w - 2, y: 1), 0,
            "top-right inside-corner pixel must be transparent")
        XCTAssertEqual(alpha(x: 100, y: 100), 255,
            "center pixel must be opaque")
    }

    /// Visual parity between the legacy NSBezierPath / NSGraphicsContext
    /// rasterizer and the new CGPath / CGContext rasterizer. The two
    /// rasterizers do not produce bit-identical antialiasing along the
    /// rounded edge — that's a known property of moving across Cocoa /
    /// CoreGraphics rendering layers, not a regression. Asserts:
    ///   * Same output dimensions.
    ///   * Interior pixels (well away from the edge AA band) match exactly.
    ///   * Channels with delta > 1 represent < 1% of the bitmap (in practice
    ///     ~0.1% — a thin sliver along the rounded corner arc).
    func testNewMatchesLegacyWithinAATolerance() throws {
        let input = referencePNG(width: 200, height: 200)
        let legacyData = try XCTUnwrap(_legacyRoundedPNG_forComparison(
            fromPNG: input, cornerRadius: 32))
        let newData = try XCTUnwrap(_roundedPNG(fromPNG: input, cornerRadius: 32))

        let legacy = try XCTUnwrap(decodeBitmap(from: legacyData))
        let new = try XCTUnwrap(decodeBitmap(from: newData))
        XCTAssertEqual(legacy.cg.width, new.cg.width)
        XCTAssertEqual(legacy.cg.height, new.cg.height)
        XCTAssertEqual(legacy.pixels.count, new.pixels.count)

        let totalChannels = legacy.pixels.count
        var diffCount = 0
        var maxDelta: Int = 0
        for i in 0..<totalChannels {
            let d = abs(Int(legacy.pixels[i]) - Int(new.pixels[i]))
            if d > maxDelta { maxDelta = d }
            if d > 1 { diffCount += 1 }
        }
        let driftFraction = Double(diffCount) / Double(totalChannels)
        XCTAssertLessThan(driftFraction, 0.01,
            "AA-band drift exceeded 1% of channels: \(diffCount)/\(totalChannels) (max delta: \(maxDelta))")

        // Pin a few clearly-interior pixels exactly. They're nowhere near
        // the rounded corner arc — any difference here would be a real bug.
        let w = legacy.cg.width
        for (x, y) in [(50, 50), (100, 100), (150, 150), (50, 150), (150, 50)] {
            let idx = y * w * 4 + x * 4
            for c in 0..<4 {
                XCTAssertEqual(legacy.pixels[idx + c], new.pixels[idx + c],
                    "interior pixel (\(x),\(y)) channel \(c) must match exactly")
            }
        }
    }
}

#endif

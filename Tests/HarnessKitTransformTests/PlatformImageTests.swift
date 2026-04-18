//
//  PlatformImageTests.swift
//  HarnessKitTransformTests
//

import XCTest
import CoreGraphics
import ImageIO
import UniformTypeIdentifiers
@testable import HarnessKitTransform

final class PlatformImageTests: XCTestCase {

    private func writeSolidPNG(size: CGSize, to url: URL) throws {
        let cs = CGColorSpaceCreateDeviceRGB()
        guard let ctx = CGContext(
            data: nil,
            width: Int(size.width),
            height: Int(size.height),
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: cs,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else {
            throw NSError(domain: "PlatformImageTests", code: 1)
        }
        ctx.setFillColor(red: 0.2, green: 0.5, blue: 0.9, alpha: 1.0)
        ctx.fill(CGRect(origin: .zero, size: size))
        guard let cg = ctx.makeImage() else {
            throw NSError(domain: "PlatformImageTests", code: 2)
        }
        let type = UTType.png.identifier as CFString
        guard let dest = CGImageDestinationCreateWithURL(url as CFURL, type, 1, nil) else {
            throw NSError(domain: "PlatformImageTests", code: 3)
        }
        CGImageDestinationAddImage(dest, cg, nil)
        guard CGImageDestinationFinalize(dest) else {
            throw NSError(domain: "PlatformImageTests", code: 4)
        }
    }

    /// Writes a JPEG whose pixel payload is `size` but whose container
    /// tags it with EXIF orientation 6 (rotate 90° CW). After a
    /// transform-aware load the displayed dimensions are `(height, width)`.
    private func writeJPEGWithOrientation(
        size: CGSize,
        orientation: CGImagePropertyOrientation,
        to url: URL
    ) throws {
        let cs = CGColorSpaceCreateDeviceRGB()
        guard let ctx = CGContext(
            data: nil,
            width: Int(size.width),
            height: Int(size.height),
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: cs,
            bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue
        ) else {
            throw NSError(domain: "PlatformImageTests", code: 10)
        }
        ctx.setFillColor(red: 0.8, green: 0.2, blue: 0.1, alpha: 1.0)
        ctx.fill(CGRect(origin: .zero, size: size))
        guard let cg = ctx.makeImage() else {
            throw NSError(domain: "PlatformImageTests", code: 11)
        }
        let type = UTType.jpeg.identifier as CFString
        guard let dest = CGImageDestinationCreateWithURL(url as CFURL, type, 1, nil) else {
            throw NSError(domain: "PlatformImageTests", code: 12)
        }
        let props: [CFString: Any] = [
            kCGImagePropertyOrientation: orientation.rawValue,
            kCGImageDestinationLossyCompressionQuality: 0.9,
        ]
        CGImageDestinationAddImage(dest, cg, props as CFDictionary)
        guard CGImageDestinationFinalize(dest) else {
            throw NSError(domain: "PlatformImageTests", code: 13)
        }
    }

    func testDownsampledLoaderReducesSize() throws {
        let tmp = FileManager.default.temporaryDirectory
            .appendingPathComponent("harnesskit-downsample-\(UUID().uuidString).png")
        try writeSolidPNG(size: CGSize(width: 2000, height: 2000), to: tmp)
        defer { try? FileManager.default.removeItem(at: tmp) }

        guard let img = platformImage(contentsOf: tmp, maxPixelSize: 512) else {
            XCTFail("loader returned nil")
            return
        }
        let px = imagePixelSize(img)
        XCTAssertLessThanOrEqual(max(px.width, px.height), 512)
        XCTAssertGreaterThan(min(px.width, px.height), 0)
    }

    func testDownsampledLoaderNilIsFullResolution() throws {
        let tmp = FileManager.default.temporaryDirectory
            .appendingPathComponent("harnesskit-downsample-nil-\(UUID().uuidString).png")
        try writeSolidPNG(size: CGSize(width: 1024, height: 768), to: tmp)
        defer { try? FileManager.default.removeItem(at: tmp) }

        guard let img = platformImage(contentsOf: tmp, maxPixelSize: nil) else {
            XCTFail("loader returned nil")
            return
        }
        let px = imagePixelSize(img)
        XCTAssertEqual(px.width, 1024)
        XCTAssertEqual(px.height, 768)
    }

    func testDownsampledLoaderRespectsEXIFOrientation() throws {
        let tmp = FileManager.default.temporaryDirectory
            .appendingPathComponent("harnesskit-exif-\(UUID().uuidString).jpg")
        try writeJPEGWithOrientation(size: CGSize(width: 400, height: 200), orientation: .right, to: tmp)
        defer { try? FileManager.default.removeItem(at: tmp) }

        guard let img = platformImage(contentsOf: tmp, maxPixelSize: 1024) else {
            XCTFail("loader returned nil")
            return
        }
        let px = imagePixelSize(img)
        XCTAssertEqual(px.width, 200, "EXIF .right should swap width/height")
        XCTAssertEqual(px.height, 400, "EXIF .right should swap width/height")
    }
}

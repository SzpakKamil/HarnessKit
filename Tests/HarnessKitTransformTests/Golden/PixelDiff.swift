//
//  PixelDiff.swift
//  HarnessKitTransformTests
//
//  Rasterizes two CGImages into byte-identical RGBA8 buffers and reports the
//  first channel that differs by more than `tolerance`. Report is a short
//  human-readable string rather than a structured type because the only
//  consumer is XCTFail's message.
//

import Foundation
import CoreGraphics
import ImageIO

enum PixelDiff {
    /// Decodes a PNG into a CGImage without going through NSImage/UIImage.
    static func decode(pngData: Data) -> CGImage? {
        guard let source = CGImageSourceCreateWithData(pngData as CFData, nil),
              let image = CGImageSourceCreateImageAtIndex(source, 0, nil) else {
            return nil
        }
        return image
    }

    /// Returns `nil` when images match within tolerance, otherwise a short
    /// description of the first diff (and counts of diffs overall).
    static func compare(
        actual: CGImage, expected: CGImage, tolerance: UInt8
    ) -> String? {
        guard actual.width == expected.width, actual.height == expected.height else {
            return "size mismatch: actual=\(actual.width)x\(actual.height), expected=\(expected.width)x\(expected.height)"
        }
        guard let a = render(actual) else { return "failed to render actual into RGBA8" }
        guard let e = render(expected) else { return "failed to render expected into RGBA8" }
        guard a.bytes.count == e.bytes.count else {
            return "byte-count mismatch: actual=\(a.bytes.count), expected=\(e.bytes.count)"
        }

        var firstDiff: (index: Int, actual: UInt8, expected: UInt8)?
        var diffCount = 0
        var maxDelta: UInt8 = 0

        a.bytes.withUnsafeBufferPointer { aBuf in
            e.bytes.withUnsafeBufferPointer { eBuf in
                let count = aBuf.count
                for i in 0..<count {
                    let av = aBuf[i], ev = eBuf[i]
                    let delta: UInt8 = av >= ev ? av - ev : ev - av
                    if delta > tolerance {
                        if firstDiff == nil { firstDiff = (i, av, ev) }
                        diffCount += 1
                        if delta > maxDelta { maxDelta = delta }
                    }
                }
            }
        }

        guard let first = firstDiff else { return nil }
        let pixelIndex = first.index / 4
        let x = pixelIndex % a.width
        let y = pixelIndex / a.width
        let channelNames = ["R", "G", "B", "A"]
        let channel = channelNames[first.index % 4]
        return """
        \(diffCount) byte(s) outside tolerance \(tolerance) (max delta \(maxDelta)); \
        first at pixel (\(x),\(y)) channel \(channel): actual=\(first.actual), expected=\(first.expected)
        """
    }

    private struct Raster {
        let width: Int
        let bytes: [UInt8]
    }

    /// Rasterizes `image` into a premultiplied RGBA8 buffer using a
    /// deterministic context so comparisons are independent of the source
    /// image's native color space / pixel format.
    private static func render(_ image: CGImage) -> Raster? {
        let width = image.width
        let height = image.height
        let bytesPerRow = width * 4
        var bytes = [UInt8](repeating: 0, count: bytesPerRow * height)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let info: CGBitmapInfo = [
            CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue),
            CGBitmapInfo.byteOrder32Big
        ]
        let ok: Bool = bytes.withUnsafeMutableBufferPointer { buf -> Bool in
            guard let ctx = CGContext(
                data: buf.baseAddress,
                width: width, height: height,
                bitsPerComponent: 8, bytesPerRow: bytesPerRow,
                space: colorSpace, bitmapInfo: info.rawValue
            ) else { return false }
            ctx.clear(CGRect(x: 0, y: 0, width: width, height: height))
            ctx.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
            return true
        }
        guard ok else { return nil }
        return Raster(width: width, bytes: bytes)
    }
}

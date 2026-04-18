//
//  BezelImageCacheTests.swift
//  HarnessKitTransformTests
//

import XCTest
import CoreGraphics
import ImageIO
import UniformTypeIdentifiers
@testable import HarnessKitTransform

final class BezelImageCacheTests: XCTestCase {

    override func setUp() {
        super.setUp()
        BezelImageCache.shared.clear()
        BezelImageCache.shared.setBudget(bytes: 128 * 1024 * 1024)
    }

    // MARK: - Fixtures

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
            throw NSError(domain: "BezelImageCacheTests", code: 1)
        }
        ctx.setFillColor(red: 0.3, green: 0.6, blue: 0.2, alpha: 1.0)
        ctx.fill(CGRect(origin: .zero, size: size))
        guard let cg = ctx.makeImage() else {
            throw NSError(domain: "BezelImageCacheTests", code: 2)
        }
        guard let dest = CGImageDestinationCreateWithURL(
            url as CFURL, UTType.png.identifier as CFString, 1, nil
        ) else {
            throw NSError(domain: "BezelImageCacheTests", code: 3)
        }
        CGImageDestinationAddImage(dest, cg, nil)
        guard CGImageDestinationFinalize(dest) else {
            throw NSError(domain: "BezelImageCacheTests", code: 4)
        }
    }

    private func tempPNG(size: CGSize) throws -> URL {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("bezelcache-\(UUID().uuidString).png")
        try writeSolidPNG(size: size, to: url)
        return url
    }

    // MARK: - Tests

    func testRepeatedLookupsHitTheCache() throws {
        let url = try tempPNG(size: CGSize(width: 200, height: 200))
        defer { try? FileManager.default.removeItem(at: url) }

        for _ in 0..<10 {
            XCTAssertNotNil(BezelImageCache.shared.image(for: url, maxPixelSize: nil))
        }
        XCTAssertEqual(BezelImageCache.shared.hitCount, 9)
        XCTAssertEqual(BezelImageCache.shared.missCount, 1)
        XCTAssertEqual(BezelImageCache.shared.resourcesHeld, 1)
    }

    func testEvictsUnderTightBudget() throws {
        // Each 400×400 RGBA8 image is ~640 KB. Budget 16 MB is the
        // clamp floor, which fits ~25 such images — make the images
        // large enough so three of them overflow the floor.
        //
        // Use 2048×2048 ≈ 16 MB each, set budget to 24 MB → exactly
        // one image fits, two get evicted.
        let a = try tempPNG(size: CGSize(width: 2048, height: 2048))
        let b = try tempPNG(size: CGSize(width: 2048, height: 2048))
        let c = try tempPNG(size: CGSize(width: 2048, height: 2048))
        defer {
            try? FileManager.default.removeItem(at: a)
            try? FileManager.default.removeItem(at: b)
            try? FileManager.default.removeItem(at: c)
        }

        BezelImageCache.shared.setBudget(bytes: 24 * 1024 * 1024)

        XCTAssertNotNil(BezelImageCache.shared.image(for: a, maxPixelSize: nil))
        XCTAssertNotNil(BezelImageCache.shared.image(for: b, maxPixelSize: nil))
        XCTAssertNotNil(BezelImageCache.shared.image(for: c, maxPixelSize: nil))

        XCTAssertEqual(BezelImageCache.shared.resourcesHeld, 1,
                       "with 24 MB budget only the most-recent 16 MB image should remain")
    }

    func testClearEmptiesCache() throws {
        let url = try tempPNG(size: CGSize(width: 200, height: 200))
        defer { try? FileManager.default.removeItem(at: url) }

        XCTAssertNotNil(BezelImageCache.shared.image(for: url, maxPixelSize: nil))
        XCTAssertEqual(BezelImageCache.shared.resourcesHeld, 1)

        BezelImageCache.shared.clear()
        XCTAssertEqual(BezelImageCache.shared.resourcesHeld, 0)
        XCTAssertEqual(BezelImageCache.shared.liveBytes, 0)
    }

    func testDifferentMaxPixelSizesCacheSeparately() throws {
        let url = try tempPNG(size: CGSize(width: 2000, height: 2000))
        defer { try? FileManager.default.removeItem(at: url) }

        XCTAssertNotNil(BezelImageCache.shared.image(for: url, maxPixelSize: 512))
        XCTAssertNotNil(BezelImageCache.shared.image(for: url, maxPixelSize: 1024))
        XCTAssertNotNil(BezelImageCache.shared.image(for: url, maxPixelSize: nil))
        XCTAssertEqual(BezelImageCache.shared.resourcesHeld, 3)
        XCTAssertEqual(BezelImageCache.shared.missCount, 3)
        XCTAssertEqual(BezelImageCache.shared.hitCount, 0)
    }

    func testSetBudgetClampsToFloor() {
        BezelImageCache.shared.setBudget(bytes: 1024)  // way below 16 MB floor
        XCTAssertEqual(BezelImageCache.shared.budgetBytes, 16 * 1024 * 1024)
    }

    func testInvalidateCachesClearsBezelCache() async throws {
        let url = try tempPNG(size: CGSize(width: 200, height: 200))
        defer { try? FileManager.default.removeItem(at: url) }

        XCTAssertNotNil(BezelImageCache.shared.image(for: url, maxPixelSize: nil))
        XCTAssertEqual(BezelImageCache.shared.resourcesHeld, 1)

        await HarnessKitCatalogue.shared.invalidateCaches()
        XCTAssertEqual(BezelImageCache.shared.resourcesHeld, 0)
    }
}

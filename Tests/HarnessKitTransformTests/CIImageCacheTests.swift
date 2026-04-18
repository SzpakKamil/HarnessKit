//
//  CIImageCacheTests.swift
//  HarnessKitTransformTests
//

import XCTest
import CoreGraphics
@testable import HarnessKitTransform

final class CIImageCacheTests: XCTestCase {

    override func setUp() {
        super.setUp()
        CIImageCache.clear()
        CIImageCache.setCapacity(32)
    }

    func testSameKeyReturnsCached() {
        let size = CGSize(width: 512, height: 512)
        _ = CIImageCache.linearGradientMask(size: size, direction: .topToBottom)
        _ = CIImageCache.linearGradientMask(size: size, direction: .topToBottom)
        _ = CIImageCache.linearGradientMask(size: size, direction: .topToBottom)
        XCTAssertEqual(CIImageCache.missCount, 1)
        XCTAssertEqual(CIImageCache.hitCount, 2)
        XCTAssertEqual(CIImageCache.count, 1)
    }

    func testDifferentDirectionsKeySeparately() {
        let size = CGSize(width: 256, height: 256)
        _ = CIImageCache.linearGradientMask(size: size, direction: .topToBottom)
        _ = CIImageCache.linearGradientMask(size: size, direction: .bottomToTop)
        _ = CIImageCache.linearGradientMask(size: size, direction: .leftToRight)
        _ = CIImageCache.linearGradientMask(size: size, direction: .rightToLeft)
        XCTAssertEqual(CIImageCache.missCount, 4)
        XCTAssertEqual(CIImageCache.hitCount, 0)
        XCTAssertEqual(CIImageCache.count, 4)
    }

    func testDifferentSizesKeySeparately() {
        _ = CIImageCache.linearGradientMask(size: CGSize(width: 100, height: 100), direction: .topToBottom)
        _ = CIImageCache.linearGradientMask(size: CGSize(width: 200, height: 100), direction: .topToBottom)
        XCTAssertEqual(CIImageCache.count, 2)
    }

    func testFIFOEvictionRespectsCapacity() {
        CIImageCache.setCapacity(3)
        _ = CIImageCache.linearGradientMask(size: CGSize(width: 100, height: 100), direction: .topToBottom)
        _ = CIImageCache.linearGradientMask(size: CGSize(width: 200, height: 100), direction: .topToBottom)
        _ = CIImageCache.linearGradientMask(size: CGSize(width: 300, height: 100), direction: .topToBottom)
        XCTAssertEqual(CIImageCache.count, 3)

        // Insert a 4th; the 1st (100×100) should be evicted.
        _ = CIImageCache.linearGradientMask(size: CGSize(width: 400, height: 100), direction: .topToBottom)
        XCTAssertEqual(CIImageCache.count, 3)

        // Re-query 100×100: cache miss (evicted), re-inserts.
        _ = CIImageCache.linearGradientMask(size: CGSize(width: 100, height: 100), direction: .topToBottom)
        XCTAssertEqual(CIImageCache.count, 3)
        // Now misses = 5 (first 4 inserts + re-insert of evicted 100×100)
        XCTAssertEqual(CIImageCache.missCount, 5)
    }

    func testClearEmptiesCache() {
        _ = CIImageCache.linearGradientMask(size: CGSize(width: 100, height: 100), direction: .topToBottom)
        _ = CIImageCache.linearGradientMask(size: CGSize(width: 200, height: 100), direction: .topToBottom)
        XCTAssertEqual(CIImageCache.count, 2)
        CIImageCache.clear()
        XCTAssertEqual(CIImageCache.count, 0)
        XCTAssertEqual(CIImageCache.hitCount, 0)
        XCTAssertEqual(CIImageCache.missCount, 0)
    }

    func testInvalidateCachesClearsCIImageCache() async {
        _ = CIImageCache.linearGradientMask(size: CGSize(width: 100, height: 100), direction: .topToBottom)
        XCTAssertEqual(CIImageCache.count, 1)
        await HarnessKitCatalogue.shared.invalidateCaches()
        XCTAssertEqual(CIImageCache.count, 0)
    }
}

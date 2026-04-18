//
//  ContinuousPathCacheTests.swift
//  HarnessKitTransformTests
//
//  Covers Part XI / Item 2 — continuousRoundedRectPath LRU cache.
//  Asserts:
//  - Hits on repeated keys (no rebuild).
//  - Bounded size (map.count never exceeds maxEntries).
//  - Degenerate radius 0 short-circuits around the cache.
//  - `clear()` wipes state and hooks through `invalidateCaches()`.
//  - Cached paths preserve origin correctly (stored at zero, translated
//    on read).
//

import XCTest
import CoreGraphics
@testable import HarnessKitTransform

final class ContinuousPathCacheTests: XCTestCase {

    override func setUp() {
        super.setUp()
        ContinuousPathCache.clear()
    }

    // MARK: - Hit/miss behavior

    func testRepeatedSameKeyHitsCache() {
        let rect = CGRect(x: 0, y: 0, width: 100, height: 50)
        _ = ContinuousPathCache.path(rect: rect, radius: 10)
        _ = ContinuousPathCache.path(rect: rect, radius: 10)
        _ = ContinuousPathCache.path(rect: rect, radius: 10)

        XCTAssertEqual(ContinuousPathCache.missCount, 1, "first call is a miss")
        XCTAssertEqual(ContinuousPathCache.hitCount, 2, "subsequent calls hit")
        XCTAssertEqual(ContinuousPathCache.resourcesHeld, 1, "one entry")
    }

    func testDifferentKeysCacheSeparately() {
        _ = ContinuousPathCache.path(rect: CGRect(x: 0, y: 0, width: 100, height: 50), radius: 10)
        _ = ContinuousPathCache.path(rect: CGRect(x: 0, y: 0, width: 100, height: 50), radius: 20)
        _ = ContinuousPathCache.path(rect: CGRect(x: 0, y: 0, width: 200, height: 50), radius: 10)

        XCTAssertEqual(ContinuousPathCache.missCount, 3)
        XCTAssertEqual(ContinuousPathCache.hitCount, 0)
        XCTAssertEqual(ContinuousPathCache.resourcesHeld, 3)
    }

    func testZeroRadiusBypassesCache() {
        let rect = CGRect(x: 0, y: 0, width: 100, height: 50)
        _ = ContinuousPathCache.path(rect: rect, radius: 0)
        _ = ContinuousPathCache.path(rect: rect, radius: 0)
        XCTAssertEqual(ContinuousPathCache.missCount, 0, "radius 0 doesn't touch the cache")
        XCTAssertEqual(ContinuousPathCache.hitCount, 0)
        XCTAssertEqual(ContinuousPathCache.resourcesHeld, 0)
    }

    // MARK: - Bounded growth

    /// Critical leak check: insert > maxEntries distinct keys and confirm
    /// map.count stays at maxEntries. Prevents the cache from growing
    /// unbounded in long-lived hosts (e.g. a Framely app rendering many
    /// distinct layer sizes).
    func testResourcesHeldNeverExceedsMaxEntries() {
        let maxEntries = 32  // must match ContinuousPathCache.maxEntries
        for i in 0..<(maxEntries * 3) {
            let w = CGFloat(100 + i)
            _ = ContinuousPathCache.path(
                rect: CGRect(x: 0, y: 0, width: w, height: 50),
                radius: 10
            )
        }
        XCTAssertLessThanOrEqual(ContinuousPathCache.resourcesHeld, maxEntries,
                                 "map must never exceed maxEntries — unbounded growth is a leak")
    }

    // MARK: - Origin handling

    /// Cached entry is stored at `.zero` origin, but callers get a path
    /// translated to their requested origin. Verifies the bounding box.
    func testCachedPathRespectsCallerOrigin() {
        let sizedRect = CGRect(x: 0, y: 0, width: 100, height: 50)
        let path1 = ContinuousPathCache.path(rect: sizedRect, radius: 10)
        XCTAssertEqual(path1.boundingBoxOfPath.origin.x, 0, accuracy: 0.5)
        XCTAssertEqual(path1.boundingBoxOfPath.origin.y, 0, accuracy: 0.5)

        // Same size, non-zero origin — should hit the cache and translate
        let offsetRect = CGRect(x: 50, y: 25, width: 100, height: 50)
        let path2 = ContinuousPathCache.path(rect: offsetRect, radius: 10)
        XCTAssertEqual(path2.boundingBoxOfPath.origin.x, 50, accuracy: 0.5)
        XCTAssertEqual(path2.boundingBoxOfPath.origin.y, 25, accuracy: 0.5)

        XCTAssertEqual(ContinuousPathCache.hitCount, 1,
                       "different-origin same-size should hit the cache")
    }

    // MARK: - Clear

    func testClearWipesState() {
        _ = ContinuousPathCache.path(rect: CGRect(x: 0, y: 0, width: 100, height: 50), radius: 10)
        _ = ContinuousPathCache.path(rect: CGRect(x: 0, y: 0, width: 100, height: 50), radius: 10)
        XCTAssertEqual(ContinuousPathCache.resourcesHeld, 1)
        XCTAssertEqual(ContinuousPathCache.hitCount, 1)

        ContinuousPathCache.clear()
        XCTAssertEqual(ContinuousPathCache.resourcesHeld, 0)
        XCTAssertEqual(ContinuousPathCache.hitCount, 0)
        XCTAssertEqual(ContinuousPathCache.missCount, 0)
    }

    func testInvalidateCachesClearsPathCache() async {
        _ = ContinuousPathCache.path(rect: CGRect(x: 0, y: 0, width: 100, height: 50), radius: 10)
        XCTAssertEqual(ContinuousPathCache.resourcesHeld, 1)
        await HarnessKitCatalogue.shared.invalidateCaches()
        XCTAssertEqual(ContinuousPathCache.resourcesHeld, 0,
                       "invalidateCaches() must clear the continuous-path cache")
    }

    // MARK: - Quantization

    /// Floating-point drift within 0.01 pt must still hit the cache.
    /// Prevents the cache from exploding on pipelines that compute rects
    /// via `width * 0.8` etc.
    func testQuantizationCollapsesNearbyKeys() {
        _ = ContinuousPathCache.path(rect: CGRect(x: 0, y: 0, width: 100.001, height: 50.001), radius: 10.0)
        _ = ContinuousPathCache.path(rect: CGRect(x: 0, y: 0, width: 100.0, height: 50.0), radius: 10.0001)
        XCTAssertEqual(ContinuousPathCache.missCount, 1,
                       "near-equal floats should quantize to the same key")
        XCTAssertEqual(ContinuousPathCache.hitCount, 1)
        XCTAssertEqual(ContinuousPathCache.resourcesHeld, 1)
    }
}

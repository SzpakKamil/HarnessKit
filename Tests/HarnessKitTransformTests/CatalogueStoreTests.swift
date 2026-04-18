//
//  CatalogueStoreTests.swift
//  HarnessKitTransformTests
//
//  Covers §S5.6 — per-name JSON byte cache on CatalogueStore.
//

import XCTest
@testable import HarnessKitTransform

final class CatalogueStoreTests: XCTestCase {

    private let store = CatalogueStore.shared

    override func setUp() async throws {
        try await super.setUp()
        store.clearJSONCache()
        store.resetJSONCacheCounters()
    }

    /// Repeated `json(forCatalogueName:)` calls within the same generation
    /// must hit the cache after the first miss — disk-read counter stays at 1.
    func testJSONCachedWithinGeneration() {
        let first = store.json(forCatalogueName: "phone_devices")
        XCTAssertNotNil(first, "phone_devices.json should resolve via the SPM bundle fallback")
        XCTAssertEqual(store.jsonDiskReadCount, 1, "first call is a miss")

        for _ in 0..<10 {
            let hit = store.json(forCatalogueName: "phone_devices")
            XCTAssertEqual(hit, first, "cached bytes must equal the first load")
        }
        XCTAssertEqual(store.jsonDiskReadCount, 1, "subsequent calls in the same generation must NOT touch disk")
    }

    /// Different catalogue names cache independently — each first-call adds one
    /// to the disk-read counter, subsequent calls per name hit the cache.
    func testDifferentNamesCacheSeparately() {
        let names = ["phone_devices", "pad_devices", "tv_devices", "watch_devices", "vision_devices", "mac_devices"]
        for name in names {
            XCTAssertNotNil(store.json(forCatalogueName: name))
        }
        XCTAssertEqual(store.jsonDiskReadCount, names.count, "one disk read per distinct name")

        // Re-query each: all hits.
        for name in names {
            XCTAssertNotNil(store.json(forCatalogueName: name))
        }
        XCTAssertEqual(store.jsonDiskReadCount, names.count, "re-queries hit the cache")
    }

    /// Bumping the generation must invalidate cache entries — next call is a
    /// disk read again. Mirrors the GenerationCache semantics from §S5.3.
    func testGenerationBumpInvalidatesCache() {
        _ = store.json(forCatalogueName: "phone_devices")
        XCTAssertEqual(store.jsonDiskReadCount, 1)

        // Hit
        _ = store.json(forCatalogueName: "phone_devices")
        XCTAssertEqual(store.jsonDiskReadCount, 1)

        store.invalidateCaches()  // bumps generation

        // Forced re-read
        _ = store.json(forCatalogueName: "phone_devices")
        XCTAssertEqual(store.jsonDiskReadCount, 2, "generation bump must force a re-read")

        // Now cached again at the new generation
        _ = store.json(forCatalogueName: "phone_devices")
        XCTAssertEqual(store.jsonDiskReadCount, 2)
    }

    /// Missing-name lookups return nil and do NOT poison the cache. A later
    /// successful load for a different name must still cache normally.
    func testMissingNameDoesNotPoisonCache() {
        XCTAssertNil(store.json(forCatalogueName: "nonexistent_catalogue_xyz"))
        XCTAssertEqual(store.jsonDiskReadCount, 1, "miss bumps the counter even if no data was found")

        XCTAssertNotNil(store.json(forCatalogueName: "phone_devices"))
        XCTAssertNotNil(store.json(forCatalogueName: "phone_devices"))
        XCTAssertEqual(store.jsonDiskReadCount, 2, "phone_devices loaded once, then cached")
    }
}

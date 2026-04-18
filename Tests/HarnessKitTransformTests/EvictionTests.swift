//
//  EvictionTests.swift
//  HarnessKitTransformTests
//
//  Covers §S5.5 — async eviction with cancellation and coalescing.
//  Uses a temp-directory ObjectCache instance for the loop-level tests
//  so the user's real `~/Library/Caches/HarnessKit/` is never touched.
//  The coalescing test uses the singleton (it has to — HarnessKitCatalogue
//  hard-references `ObjectCache.shared`) but only triggers eviction against
//  whatever manifest happens to be installed; eviction is correct in either
//  state (no manifest → early return; real manifest → no false positives).
//

import XCTest
@testable import HarnessKitTransform

final class EvictionTests: XCTestCase {

    private var tempRoot: URL!
    private var cache: ObjectCache!
    private var priorManifest: Manifest?

    override func setUp() async throws {
        try await super.setUp()
        tempRoot = FileManager.default.temporaryDirectory
            .appendingPathComponent("HarnessKitEvictionTest-\(UUID().uuidString)", isDirectory: true)
        cache = ObjectCache(rootURL: tempRoot)
        cache.resetEvictionCounters()
        priorManifest = CatalogueStore.shared.manifest

        // Pre-warm the actor's `evictionTask` slot so the coalescing-test
        // assertions are deterministic regardless of test ordering. Without
        // this, the first test that calls `evictStaleCache()` would spawn a
        // task and bump `runsStarted`; later tests would see `evictionTask`
        // set and never spawn another, conflating "first run" with
        // "coalescing." After setUp, `evictionTask` always points to a
        // completed task and counters are zeroed.
        await HarnessKitCatalogue.shared.evictStaleCache()
        ObjectCache.shared.resetEvictionCounters()
    }

    override func tearDown() async throws {
        try? FileManager.default.removeItem(at: tempRoot)
        if let prior = priorManifest {
            CatalogueStore.shared.setManifest(prior)
        }
        try await super.tearDown()
    }

    // MARK: - Helpers

    @discardableResult
    private func writeFile(named hash: String) throws -> URL {
        let url = cache.objectsURL.appendingPathComponent(hash)
        try Data("x".utf8).write(to: url)
        return url
    }

    private func installManifest(referencing hashes: [String]) {
        var files: [String: ManifestFile] = [:]
        for h in hashes {
            files["fake/\(h).png"] = ManifestFile(sha256: h, size: 1)
        }
        let m = Manifest(
            schemaVersion: 1,
            catalogueVersion: "test",
            generatedAt: "2026-04-18",
            notice: nil,
            files: files
        )
        CatalogueStore.shared.setManifest(m)
    }

    // MARK: - Tests

    /// Regression: eviction still deletes unreferenced files and keeps
    /// referenced ones. Validates the new fire-and-forget refresh path
    /// didn't break the underlying eviction algorithm.
    func testEvictionDeletesUnreferencedFiles() throws {
        let kept = try writeFile(named: "kept-hash")
        let stale1 = try writeFile(named: "stale-hash-1")
        let stale2 = try writeFile(named: "stale-hash-2")
        installManifest(referencing: ["kept-hash"])

        cache.evictUnreferencedObjects()

        XCTAssertTrue(FileManager.default.fileExists(atPath: kept.path),
            "referenced hash must survive eviction")
        XCTAssertFalse(FileManager.default.fileExists(atPath: stale1.path))
        XCTAssertFalse(FileManager.default.fileExists(atPath: stale2.path))
        XCTAssertEqual(cache.evictionRunsStarted, 1)
        XCTAssertEqual(cache.evictionRunsCompleted, 1)
        XCTAssertEqual(cache.evictionItemsConsidered, 3)
        XCTAssertEqual(cache.evictionItemsRemoved, 2)
    }

    /// `Task.isCancelled` checked at the top of each loop iteration must
    /// bail the run before any items are processed when cancellation has
    /// already been requested. This is the hook a racing `refresh()` relies
    /// on to preempt an in-flight eviction whose manifest snapshot is stale.
    func testEvictionRespectsTaskCancellation() async throws {
        for i in 0..<10 {
            try writeFile(named: "stale-\(i)")
        }
        installManifest(referencing: [])

        let cache = self.cache!
        let task = Task.detached {
            cache.evictUnreferencedObjects()
        }
        task.cancel()
        await task.value

        XCTAssertEqual(cache.evictionRunsStarted, 1)
        XCTAssertEqual(cache.evictionRunsCompleted, 0,
            "cancelled run should NOT increment runsCompleted")
        XCTAssertEqual(cache.evictionItemsConsidered, 0,
            "cancellation lands at the first loop iteration before any item is processed")
        // The stale files should still be on disk — the cancelled run never reached them.
        let surviving = (try? FileManager.default.contentsOfDirectory(at: cache.objectsURL,
                                                                       includingPropertiesForKeys: nil)) ?? []
        XCTAssertEqual(surviving.count, 10,
            "cancelled eviction must leave files intact for the replacement run to process")
    }

    /// Sequential `evictStaleCache()` calls coalesce — `evictionTask` is
    /// non-nil after setUp's pre-warm (pointing to a completed task), so
    /// every subsequent call takes the await-existing-task branch and never
    /// spawns a new run. `runsStarted` stays at the post-reset baseline of 0.
    func testEvictStaleCacheCoalescesSequentialCalls() async {
        let catalogue = HarnessKitCatalogue.shared
        for _ in 0..<5 {
            await catalogue.evictStaleCache()
        }
        XCTAssertEqual(ObjectCache.shared.evictionRunsStarted, 0,
            "subsequent evictStaleCache calls must coalesce onto the existing (completed) task — no new spawns")
    }

    /// Concurrent `evictStaleCache()` calls also coalesce. Same coalescing
    /// branch as the sequential case; this just confirms the actor's
    /// reentrancy on `await task.value` doesn't accidentally produce new
    /// detached tasks under contention.
    func testEvictStaleCacheCoalescesConcurrentCalls() async {
        let catalogue = HarnessKitCatalogue.shared
        await withTaskGroup(of: Void.self) { group in
            for _ in 0..<8 {
                group.addTask { await catalogue.evictStaleCache() }
            }
        }
        XCTAssertEqual(ObjectCache.shared.evictionRunsStarted, 0,
            "concurrent evictStaleCache calls must coalesce onto the existing task — no new spawns")
    }
}

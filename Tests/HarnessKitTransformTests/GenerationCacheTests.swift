//
//  GenerationCacheTests.swift
//  HarnessKitTransformTests
//

import XCTest
import Dispatch
import os.lock
@testable import HarnessKitTransform

final class GenerationCacheTests: XCTestCase {

    // MARK: - Atomic counter (no `OSAllocatedUnfairLock`, macOS 11 / iOS 14 safe)

    private final class Counter: @unchecked Sendable {
        private var _lock = os_unfair_lock_s()
        private var _value = 0

        @discardableResult
        func increment() -> Int {
            os_unfair_lock_lock(&_lock)
            defer { os_unfair_lock_unlock(&_lock) }
            _value += 1
            return _value
        }

        var value: Int {
            os_unfair_lock_lock(&_lock)
            defer { os_unfair_lock_unlock(&_lock) }
            return _value
        }
    }

    // MARK: - Tests

    /// Proves that `builder` runs **outside** the lock — two racers must be
    /// able to be inside `builder` simultaneously. The test stalls the first
    /// builder on a semaphore until the second arrives; if the lock were held
    /// across `builder()`, the second caller would block on the lock and the
    /// first caller's wait would time out.
    func testBuilderRunsConcurrentlyOutsideLock() {
        let counter = Counter()
        let builderEntered = DispatchSemaphore(value: 0)
        let builderMayProceed = DispatchSemaphore(value: 0)

        let cache = GenerationCache<Int> { [counter, builderEntered, builderMayProceed] in
            let n = counter.increment()
            builderEntered.signal()
            _ = builderMayProceed.wait(timeout: .now() + .seconds(3))
            return [n]
        }

        let bothFinished = DispatchSemaphore(value: 0)

        final class ResultBox: @unchecked Sendable {
            private let lock = NSLock()
            private var values: [[Int]] = []
            func append(_ v: [Int]) { lock.lock(); values.append(v); lock.unlock() }
            var snapshot: [[Int]] { lock.lock(); defer { lock.unlock() }; return values }
        }
        let results = ResultBox()

        for _ in 0..<2 {
            DispatchQueue.global(qos: .userInitiated).async {
                let r = cache.current()
                results.append(r)
                bothFinished.signal()
            }
        }

        XCTAssertEqual(builderEntered.wait(timeout: .now() + .seconds(2)), .success,
            "First builder did not enter within 2 s")
        XCTAssertEqual(builderEntered.wait(timeout: .now() + .seconds(2)), .success,
            "Second builder did not enter within 2 s — the lock is likely still held during builder()")

        builderMayProceed.signal()
        builderMayProceed.signal()

        XCTAssertEqual(bothFinished.wait(timeout: .now() + .seconds(3)), .success)
        XCTAssertEqual(bothFinished.wait(timeout: .now() + .seconds(3)), .success)

        XCTAssertEqual(counter.value, 2,
            "builder() must run exactly twice under contention (one redundant call accepted; not unbounded)")
        let snapshot = results.snapshot
        XCTAssertEqual(snapshot.count, 2)
        XCTAssertFalse(snapshot[0].isEmpty)
        XCTAssertFalse(snapshot[1].isEmpty)
    }

    /// Single-threaded readers must hit the fast path after the first build.
    func testBuilderRunsOnceWhenUncontended() {
        let counter = Counter()
        let cache = GenerationCache<String> { [counter] in
            counter.increment()
            return ["x"]
        }
        for _ in 0..<5 {
            XCTAssertEqual(cache.current(), ["x"])
        }
        XCTAssertEqual(counter.value, 1, "uncontended repeated reads must call builder exactly once")
    }

    /// Bumping `CatalogueStore.generation` must force the next `current()` to rebuild.
    func testGenerationBumpRebuilds() async {
        let counter = Counter()
        let cache = GenerationCache<Int> { [counter] in
            [counter.increment()]
        }
        _ = cache.current()
        let firstCount = counter.value
        await HarnessKitCatalogue.shared.invalidateCaches()
        _ = cache.current()
        XCTAssertEqual(counter.value, firstCount + 1, "generation bump must trigger one additional builder call")
    }
}

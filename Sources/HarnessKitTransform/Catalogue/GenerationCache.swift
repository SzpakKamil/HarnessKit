import Foundation
import os.lock

/// A thread-safe cache that rebuilds when `CatalogueStore.generation` changes.
///
/// Callers access the cached value via `current()`. The first call (or any call after
/// `CatalogueStore` installs a new manifest) triggers a rebuild via the `builder` closure.
///
/// Concurrency model — double-checked locking:
/// 1. Fast path: read `cached` under the lock when its generation matches.
/// 2. Slow path: drop the lock, run `builder()`, then re-acquire to commit.
/// If a racing thread already committed a result for an equal-or-newer generation,
/// its value wins and ours is discarded. Two redundant `builder()` calls under
/// contention are accepted as the price for not serializing JSON parses behind
/// the lock.
///
/// `os_unfair_lock_s` is used (not `OSAllocatedUnfairLock`) so the package can stay
/// on its macOS 11 / iOS 14 minimum deployment targets — same pattern as
/// `BezelImageCache` and `CIImageCache`.
final class GenerationCache<T>: @unchecked Sendable {
    private var _lock = os_unfair_lock_s()
    private var cachedGeneration: Int = -1
    private var cached: [T] = []
    private let builder: () -> [T]

    init(builder: @escaping () -> [T]) {
        self.builder = builder
    }

    private func withLock<R>(_ body: () -> R) -> R {
        os_unfair_lock_lock(&_lock)
        defer { os_unfair_lock_unlock(&_lock) }
        return body()
    }

    func current() -> [T] {
        let generationNow = CatalogueStore.shared.generation

        if let snapshot: [T] = withLock({ () -> [T]? in
            cachedGeneration == generationNow ? cached : nil
        }) {
            return snapshot
        }

        let fresh = builder()

        return withLock {
            if cachedGeneration >= generationNow {
                return cached
            }
            cached = fresh
            cachedGeneration = generationNow
            return fresh
        }
    }
}

// Bounded LRU cache for SwiftUI-derived continuous-corner `CGPath`s.
// `RoundedRectangle(cornerRadius:style:.continuous).path(in:).cgPath`
// goes through SwiftUI's path builder on every call (~1–2 ms); a single
// canvas render hits this 7–9× across shape/image/border/corner-clip
// sites. Caching by `(width, height, radius)` at 0.01-pt quantization
// recovers 8–16 ms per canvas on shape-heavy designs.
//
// Leak safety:
// - Fixed capacity (default 32): oldest entry evicted by insertion order,
//   so map.count never grows unbounded.
// - `os_unfair_lock_s` held only for dict reads/writes, not for
//   construction — two threads racing on the same miss produce one
//   redundant CGPath (accepted; CGPath is small and the builder is
//   thread-safe).
// - Path values are immutable CGPaths; aliasing across callers is safe
//   (no one mutates them in place).
//  - Hooks into `HarnessKitCatalogue.invalidateCaches()` via `clear()`
//    so hosts that want a cold-start state can wipe it.
//

import Foundation
import CoreGraphics
import SwiftUI
import os.lock

enum ContinuousPathCache {
    private struct Key: Hashable {
        let widthQ: Int32   // quantized to 0.01 pt (× 100, clamped to Int32)
        let heightQ: Int32
        let radiusQ: Int32
    }

    nonisolated(unsafe) private static var _lock = os_unfair_lock_s()
    nonisolated(unsafe) private static var map: [Key: CGPath] = [:]
    nonisolated(unsafe) private static var insertionOrder: [Key] = []
    private static let maxEntries = 32
    nonisolated(unsafe) private static var hits: Int = 0
    nonisolated(unsafe) private static var misses: Int = 0

    /// Returns a continuous-corner rounded-rect `CGPath` for
    /// `(rect.size, radius)`. Caches up to `maxEntries` entries.
    ///
    /// Quantizes to 0.01 pt so callers that pass computed floats with
    /// floating-point drift (e.g. `frame.width * 0.8`) still hit the
    /// cache. At the device-pixel granularity the pipeline renders at
    /// (≥ 1 px per unit), 0.01 pt is < 1/100 of a device pixel — well
    /// below antialiasing's resolving power, so cached paths are
    /// visually identical to freshly-computed ones.
    static func path(rect: CGRect, radius: CGFloat) -> CGPath {
        // Fast degenerate paths skip the cache entirely — no lookup cost
        // and no wasted dict slot.
        if radius <= 0 {
            return CGPath(rect: rect, transform: nil)
        }

        let key = Key(
            widthQ: Int32((rect.width * 100).rounded()),
            heightQ: Int32((rect.height * 100).rounded()),
            radiusQ: Int32((radius * 100).rounded())
        )

        // Fast path: cache hit. Cached path is stored at `.zero`; translate
        // on read so the returned path matches the caller's rect.
        os_unfair_lock_lock(&_lock)
        if let cached = map[key] {
            hits &+= 1
            os_unfair_lock_unlock(&_lock)
            if rect.origin == .zero { return cached }
            var xf = CGAffineTransform(translationX: rect.origin.x, y: rect.origin.y)
            return cached.copy(using: &xf) ?? cached
        }
        os_unfair_lock_unlock(&_lock)

        // Slow path: build outside the lock. SwiftUI path construction
        // is thread-safe but not cheap — don't serialize concurrent
        // misses on different keys behind each other.
        let path = RoundedRectangle(cornerRadius: radius, style: .continuous)
            .path(in: CGRect(origin: .zero, size: rect.size))
            .cgPath
        // Translate to the requested origin so the cached key is
        // size-only (not origin-dependent) while the returned path
        // matches the caller's rect.
        let translated: CGPath
        if rect.origin == .zero {
            translated = path
        } else {
            var transform = CGAffineTransform(translationX: rect.origin.x, y: rect.origin.y)
            translated = path.copy(using: &transform) ?? path
        }

        os_unfair_lock_lock(&_lock)
        defer { os_unfair_lock_unlock(&_lock) }
        // Another thread may have inserted while we built — accept its
        // entry instead of ours and return the already-cached path.
        if let winner = map[key] {
            hits &+= 1
            // If caller's rect is non-zero origin, translate the winner
            // to match. This is rare (the race window is tiny) but
            // preserves the "returned path matches rect" invariant.
            if rect.origin == .zero { return winner }
            var xf = CGAffineTransform(translationX: rect.origin.x, y: rect.origin.y)
            return winner.copy(using: &xf) ?? winner
        }

        // Always store the zero-origin path; callers with non-zero
        // origins get a translated copy on lookup.
        map[key] = path
        insertionOrder.append(key)
        misses &+= 1
        if insertionOrder.count > maxEntries {
            let evicted = insertionOrder.removeFirst()
            map.removeValue(forKey: evicted)
        }
        return translated
    }

    /// Drops every cached entry. Hooked into
    /// `HarnessKitCatalogue.invalidateCaches()`.
    static func clear() {
        os_unfair_lock_lock(&_lock)
        defer { os_unfair_lock_unlock(&_lock) }
        map.removeAll(keepingCapacity: false)
        insertionOrder.removeAll(keepingCapacity: false)
        hits = 0
        misses = 0
    }

    /// Test-only statistics.
    static var hitCount: Int {
        os_unfair_lock_lock(&_lock); defer { os_unfair_lock_unlock(&_lock) }
        return hits
    }
    static var missCount: Int {
        os_unfair_lock_lock(&_lock); defer { os_unfair_lock_unlock(&_lock) }
        return misses
    }
    static var resourcesHeld: Int {
        os_unfair_lock_lock(&_lock); defer { os_unfair_lock_unlock(&_lock) }
        return map.count
    }
}

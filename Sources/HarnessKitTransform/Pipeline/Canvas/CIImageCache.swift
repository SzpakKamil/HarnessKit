import Foundation
import CoreGraphics
import CoreImage
import os.lock

/// Process-wide cache for reusable `CIImage`s — currently just
/// linear-gradient masks used by `.progressiveBlur` and
/// `.progressiveFade` effects. Keyed on `(size, direction, start, end)`.
///
/// FIFO-bounded (default 32 entries) so the cache can't grow
/// unbounded across long Framely batch exports. Same-key repeat
/// renders hit the cache; distinct canvas sizes or directions
/// miss and allocate.
public enum CIImageCache {

    public struct GradientKey: Hashable, Sendable {
        public let width: Int
        public let height: Int
        public let direction: ProgressiveBlurDirection
        public let start: Double
        public let end: Double

        public init(width: Int, height: Int, direction: ProgressiveBlurDirection, start: Double, end: Double) {
            self.width = width
            self.height = height
            self.direction = direction
            self.start = start
            self.end = end
        }
    }

    fileprivate final class Storage: @unchecked Sendable {
        var lock = os_unfair_lock_s()
        var gradients: [GradientKey: CIImage] = [:]
        var order: [GradientKey] = []  // FIFO insertion order
        var maxEntries: Int = 32
        var hits: Int = 0
        var misses: Int = 0
    }

    private static let storage = Storage()

    // MARK: - Public API

    /// Returns a cached gradient mask `CIImage` for the given parameters,
    /// rendering and inserting on miss. `start`/`end` are currently
    /// unused by the renderer (the gradient always spans the full rect)
    /// but are in the key so future callers can use non-default stops
    /// without silent cache collisions.
    public static func linearGradientMask(
        size: CGSize,
        direction: ProgressiveBlurDirection,
        start: Double = 0,
        end: Double = 1
    ) -> CIImage? {
        let key = GradientKey(
            width: Int(size.width), height: Int(size.height),
            direction: direction, start: start, end: end
        )

        if let hit: CIImage = withLock({
            if let cached = storage.gradients[key] {
                storage.hits += 1
                return cached
            }
            return nil
        }) {
            return hit
        }

        guard let rendered = renderGradientCI(size: size, direction: direction) else {
            withLock { storage.misses += 1 }
            return nil
        }

        return withLock {
            if let existing = storage.gradients[key] {
                storage.hits += 1
                return existing
            }
            if storage.gradients.count >= storage.maxEntries,
               let oldest = storage.order.first {
                storage.order.removeFirst()
                storage.gradients.removeValue(forKey: oldest)
            }
            storage.gradients[key] = rendered
            storage.order.append(key)
            storage.misses += 1
            return rendered
        }
    }

    public static func clear() {
        withLock {
            storage.gradients.removeAll()
            storage.order.removeAll()
            storage.hits = 0
            storage.misses = 0
        }
    }

    /// Sets the maximum number of entries. Clamped to at least 1.
    public static func setCapacity(_ count: Int) {
        withLock {
            storage.maxEntries = max(count, 1)
            while storage.gradients.count > storage.maxEntries,
                  let oldest = storage.order.first {
                storage.order.removeFirst()
                storage.gradients.removeValue(forKey: oldest)
            }
        }
    }

    // MARK: - Stats

    public static var hitCount: Int { withLock { storage.hits } }
    public static var missCount: Int { withLock { storage.misses } }
    public static var count: Int { withLock { storage.gradients.count } }
    public static var capacity: Int { withLock { storage.maxEntries } }

    // MARK: - Lock

    private static func withLock<R>(_ body: () -> R) -> R {
        os_unfair_lock_lock(&storage.lock)
        defer { os_unfair_lock_unlock(&storage.lock) }
        return body()
    }
}

// MARK: - Renderer

/// Renders a gradient mask as a `CIImage`. Uses the CG-based
/// `createGradientMask` so pixel output matches pre-S3.4 behavior
/// bit-for-bit, then wraps the resulting `CGImage` as a `CIImage`.
private func renderGradientCI(size: CGSize, direction: ProgressiveBlurDirection) -> CIImage? {
    guard let cg = cgImage(from: createGradientMask(size: size, direction: direction)) else {
        return nil
    }
    return CIImage(cgImage: cg)
}

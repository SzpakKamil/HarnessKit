import Foundation
import os.lock

/// Bounded LRU cache for bezel `PlatformImage`s, keyed by
/// `(URL path, maxPixelSize)`.
///
/// Descriptor `bezelImage(…)` methods are `nonisolated func` so they
/// can't hop actors — this cache is synchronous, gated by
/// `os_unfair_lock` held only around cache bookkeeping. Image decoding
/// happens outside the lock so concurrent lookups on different keys
/// don't queue behind a slow PNG decode.
///
/// `os_unfair_lock` is used (rather than `OSAllocatedUnfairLock`) so
/// the package can stay on macOS 11 / iOS 14 minimum deployment targets.
public final class BezelImageCache: @unchecked Sendable {
    public static let shared = BezelImageCache()

    private struct Key: Hashable {
        let urlPath: String
        let maxPixelSize: Int   // 0 represents "no downsampling" (nil)
    }

    private struct Entry {
        let image: PlatformImage
        let pixelBytes: Int
        var lastAccess: UInt64
    }

    private var _lock = os_unfair_lock_s()
    private var map: [Key: Entry] = [:]
    private var accessCounter: UInt64 = 0
    private var _budgetBytes: Int = 128 * 1024 * 1024
    private var livePixelBytes: Int = 0
    private var hits: Int = 0
    private var misses: Int = 0

    private init() {}

    private func withLock<R>(_ body: () -> R) -> R {
        os_unfair_lock_lock(&_lock)
        defer { os_unfair_lock_unlock(&_lock) }
        return body()
    }

    // MARK: - Budget

    public var budgetBytes: Int { withLock { _budgetBytes } }

    /// Sets the cache budget in bytes. Clamped to a 16 MB floor so the
    /// cache always fits at least one full-resolution bezel.
    public func setBudget(bytes: Int) {
        withLock {
            _budgetBytes = max(bytes, 16 * 1024 * 1024)
            evictLocked()
        }
    }

    // MARK: - Stats

    public var hitCount: Int { withLock { hits } }
    public var missCount: Int { withLock { misses } }
    public var resourcesHeld: Int { withLock { map.count } }
    public var liveBytes: Int { withLock { livePixelBytes } }

    // MARK: - Lookup

    /// Returns a cached image for `url`, decoding and inserting on miss.
    /// `maxPixelSize == nil` means full-resolution decode; that key is
    /// distinct from any downsampled variant of the same file.
    public func image(for url: URL, maxPixelSize: Int?) -> PlatformImage? {
        let key = Key(urlPath: url.path, maxPixelSize: maxPixelSize ?? 0)

        if let cached: PlatformImage = withLock({ () -> PlatformImage? in
            guard var hit = map[key] else { return nil }
            accessCounter &+= 1
            hit.lastAccess = accessCounter
            map[key] = hit
            hits += 1
            return hit.image
        }) {
            return cached
        }

        guard let img = platformImage(contentsOf: url, maxPixelSize: maxPixelSize) else {
            withLock { misses += 1 }
            return nil
        }
        let bytes = estimatedBitmapBytes(of: img)

        return withLock {
            // Another thread may have inserted while we decoded.
            if var existing = map[key] {
                accessCounter &+= 1
                existing.lastAccess = accessCounter
                map[key] = existing
                hits += 1
                return existing.image
            }
            accessCounter &+= 1
            map[key] = Entry(image: img, pixelBytes: bytes, lastAccess: accessCounter)
            livePixelBytes += bytes
            misses += 1
            evictLocked()
            return img
        }
    }

    // MARK: - Invalidation

    public func clear() {
        withLock {
            map.removeAll()
            livePixelBytes = 0
            accessCounter = 0
            hits = 0
            misses = 0
        }
    }

    // MARK: - Eviction (called under lock)

    private func evictLocked() {
        guard livePixelBytes > _budgetBytes else { return }
        let ordered = map.sorted { $0.value.lastAccess < $1.value.lastAccess }
        for (k, e) in ordered {
            if livePixelBytes <= _budgetBytes { break }
            map.removeValue(forKey: k)
            livePixelBytes -= e.pixelBytes
        }
    }
}

/// Estimates the true backing-bitmap size of `img` using the decoded
/// `CGImage`'s `bytesPerRow * height`. Was: `pixelsWide * pixelsHigh * 4`,
/// which assumed RGBA8 — wrong for alpha-only (1 bpp), RGB (3 bpp), or
/// wide-color/HDR representations (8 bpp). Accounting-only; the cache
/// still holds the full `PlatformImage`.
///
/// Falls back to the old 4-bytes-per-pixel assumption if the CGImage
/// can't be extracted (e.g. the NSImage has no bitmap rep), keeping the
/// budget bounded even when inspection fails.
private func estimatedBitmapBytes(of img: PlatformImage) -> Int {
    if let cg = cgImage(from: img) {
        return cg.bytesPerRow * cg.height
    }
    let size = imagePixelSize(img)
    return Int(size.width * size.height) * 4
}

import Foundation

/// Resolves `*_devices.json` bytes for descriptor loaders.
///
/// Preference order:
///   1. The on-disk cache entry whose sha256 matches the current in-memory manifest.
///   2. `Bundle.module` (the offline baseline shipped with the SPM package).
///
/// Also publishes a monotonic `generation` counter that bumps whenever the manifest
/// is replaced. Descriptor loaders key their caches off this counter so they re-parse
/// JSON only when something actually changed.
/// - Important: Thread safety is guaranteed by `NSLock` protecting all mutable state.
//
// Underscore convention used across the package: an `_`-prefixed name is
// locked backing storage that callers must never touch directly. Reads and
// writes happen through the lock-acquiring computed property or method on
// the same type. Private helpers without lock coordination drop the
// underscore. See `CONTRIBUTING.md` for the full rule.
final class CatalogueStore: @unchecked Sendable {

    static let shared = CatalogueStore()

    private let lock = NSLock()
    private var _manifest: Manifest?
    private var _generation: Int = 0
    /// Per-catalogue-name JSON byte cache, keyed by the generation at the time
    /// of the last successful load. Stale entries (generation mismatch) are
    /// implicitly invalidated on next `json(forCatalogueName:)` call.
    /// Bounded at ≤ 5 entries (one per catalogue name).
    private var _jsonCache: [String: (data: Data, generation: Int)] = [:]
    /// Test-only counter — bumps on every cache miss (every time we actually
    /// touch the disk). `setManifest`-induced misses included.
    private var _jsonDiskReadCount: Int = 0

    private init() {}

    // MARK: - Manifest handoff

    /// Installs a newly-validated manifest. Called by `HarnessKitCatalogue.refresh()`.
    func setManifest(_ manifest: Manifest) {
        lock.lock(); defer { lock.unlock() }
        _manifest = manifest
        _generation &+= 1
    }

    /// Current in-memory manifest, or `nil` if `refresh()` hasn't succeeded yet.
    var manifest: Manifest? {
        lock.lock(); defer { lock.unlock() }
        return _manifest
    }

    /// Bumps every time a new manifest is installed. Cheap to read.
    var generation: Int {
        lock.lock(); defer { lock.unlock() }
        return _generation
    }

    /// Forces all generation-keyed caches (device descriptors, bezel indexes)
    /// to rebuild on next access. Call after downloading new bezel files so the
    /// indexes pick up the newly-cached URLs.
    func invalidateCaches() {
        lock.lock(); defer { lock.unlock() }
        _generation &+= 1
    }

    // MARK: - JSON resolution

    /// Returns the JSON bytes for `"catalogue/<name>.json"`.
    /// Falls back to `Bundle.module.url(forResource: name, withExtension: "json")`.
    /// Returns `nil` only if neither source exists.
    ///
    /// Per-name cache keyed by current generation: a cache hit returns the
    /// previously-loaded `Data` without touching disk. Generation bumps via
    /// `setManifest` / `invalidateCaches` invalidate cache entries implicitly
    /// (the stored generation no longer matches). Disk I/O happens outside the
    /// lock to avoid serializing the 5 catalogue first-misses behind each other.
    func json(forCatalogueName name: String) -> Data? {
        // Fast path: cache hit under lock.
        lock.lock()
        let gen = _generation
        if let hit = _jsonCache[name], hit.generation == gen {
            lock.unlock()
            return hit.data
        }
        let entry = _manifest?.files[RemotePath.cataloguePrefix + "\(name).json"]
        _jsonDiskReadCount &+= 1
        lock.unlock()

        // Slow path: disk read without lock held.
        let loaded = Self.loadJSONFromDisk(name: name, entry: entry)

        // Commit. Skip the cache write if a newer manifest landed under us —
        // its sha may point at different bytes; we accept that the next caller
        // will re-load against the newer generation.
        if let loaded {
            lock.lock()
            if _generation == gen {
                _jsonCache[name] = (data: loaded, generation: gen)
            }
            lock.unlock()
        }
        return loaded
    }

    private static func loadJSONFromDisk(name: String, entry: ManifestFile?) -> Data? {
        if let entry,
           let url = ObjectCache.shared.url(forSHA256: entry.sha256, expectedSize: entry.size),
           let data = try? Data(contentsOf: url) {
            return data
        }
        if let url = Bundle.module.url(forResource: name, withExtension: "json"),
           let data = try? Data(contentsOf: url) {
            return data
        }
        return nil
    }

    // MARK: - Test-only

    /// Test-only. Number of cache misses (and therefore disk reads attempted)
    /// since the last `resetJSONCacheCounters()`.
    var jsonDiskReadCount: Int {
        lock.lock(); defer { lock.unlock() }
        return _jsonDiskReadCount
    }

    /// Test-only. Resets the disk-read counter.
    func resetJSONCacheCounters() {
        lock.lock(); defer { lock.unlock() }
        _jsonDiskReadCount = 0
    }

    /// Test-only. Drops every cached JSON entry without bumping the generation.
    /// Useful in setUp so an assertion of "second call hits the cache" is
    /// deterministic regardless of what prior tests loaded.
    func clearJSONCache() {
        lock.lock(); defer { lock.unlock() }
        _jsonCache.removeAll()
    }

    /// Returns the on-disk URL for a bezel whose R2 relative path is `relativePath`.
    /// Cache-first; returns `nil` if not cached (caller falls back to bundle).
    func cachedBezelURL(relativePath: String) -> URL? {
        guard let entry = manifest?.files[relativePath] else { return nil }
        return ObjectCache.shared.url(forSHA256: entry.sha256, expectedSize: entry.size)
    }

    /// Every relative path in the current manifest with the given prefix, e.g. `"bezels/mac/"`.
    /// O(1) bucket lookup — the prefix index is precomputed at `setManifest(_:)` time.
    func filePaths(withPrefix prefix: String) -> [String] {
        guard let manifest else { return [] }
        return Array(manifest.filesByPrefix[prefix] ?? [])
    }
}

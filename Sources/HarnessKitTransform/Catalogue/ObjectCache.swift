import Foundation
import os.lock

/// Content-addressed file cache on disk under `~/Library/Caches/HarnessKit/`.
///
/// Layout:
///   - `manifest.json`         — most recently fetched manifest
///   - `objects/<sha256>`      — raw file bytes, keyed by their sha256
///
/// Writes are atomic via temp-file + rename so a crash mid-download can't leave
/// a half-written object with a valid sha256.
/// - Important: Thread safety relies on atomic file operations and immutable URL paths.
final class ObjectCache: @unchecked Sendable {

    static let shared = ObjectCache(rootURL: ObjectCache.defaultRootURL())

    let rootURL: URL
    let objectsURL: URL
    let manifestURL: URL

    /// Test-only counters. Eviction is fired from a `Task.detached`; tests
    /// assert on these to verify coalescing and cancellation. Locked because
    /// concurrent runs are theoretically possible if coalescing slips.
    private var _counterLock = os_unfair_lock_s()
    private var _runsStarted: Int = 0
    private var _runsCompleted: Int = 0
    private var _itemsConsidered: Int = 0
    private var _itemsRemoved: Int = 0

    /// Constructs a cache rooted at `rootURL`. Production code uses `shared`,
    /// which is anchored at `~/Library/Caches/HarnessKit/`. Tests pass a temp
    /// directory so they can populate / inspect / delete files without
    /// touching the user's real cache.
    init(rootURL: URL) {
        let fm = FileManager.default
        self.rootURL = rootURL
        self.objectsURL = rootURL.appendingPathComponent("objects", isDirectory: true)
        self.manifestURL = rootURL.appendingPathComponent("manifest.json")
        try? fm.createDirectory(at: objectsURL, withIntermediateDirectories: true)
    }

    /// Default root for the singleton. In a sandboxed app (App Store builds)
    /// this resolves inside the app's sandbox container — e.g.
    /// `~/Library/Containers/<bundle-id>/Data/Library/Caches/HarnessKit`. In a
    /// non-sandboxed app it's `~/Library/Caches/HarnessKit`. Either way the
    /// directory is private to the app and OS-evictable under disk pressure,
    /// which is exactly what we want for re-downloadable bulk assets (the
    /// manifest lets us reconstruct everything). Not backed up by iCloud, so
    /// it won't bloat users' backups.
    private static func defaultRootURL() -> URL {
        let fm = FileManager.default
        let caches = (try? fm.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true))
            ?? URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("Library/Caches", isDirectory: true)
        return caches.appendingPathComponent("HarnessKit", isDirectory: true)
    }

    // MARK: - Lookup

    /// Returns the on-disk URL for `sha256` if a file with that digest is cached
    /// *and* its size matches `expectedSize`. Does **not** recompute the hash —
    /// integrity is established at write time and trusted thereafter.
    func url(forSHA256 sha256: String, expectedSize: Int? = nil) -> URL? {
        let url = objectsURL.appendingPathComponent(sha256)
        guard let attrs = try? FileManager.default.attributesOfItem(atPath: url.path) else {
            return nil
        }
        if let expectedSize, let size = attrs[.size] as? Int, size != expectedSize {
            return nil
        }
        return url
    }

    // MARK: - Eviction

    /// Removes cached objects not referenced by the current manifest.
    /// Call after `refresh()` to free space from old bezels.
    ///
    /// Cooperative cancellation: if invoked from inside a `Task` (the default
    /// from `HarnessKitCatalogue.refresh()`), the loop bails out at the next
    /// item boundary on `Task.isCancelled`. Outside a Task, `Task.isCancelled`
    /// returns `false`, so synchronous callers see no behavior change.
    func evictUnreferencedObjects() {
        bumpRunsStarted()

        guard let manifest = CatalogueStore.shared.manifest else {
            bumpRunsCompleted()
            return
        }
        let referencedHashes = Set(manifest.files.values.map(\.sha256))

        guard let contents = try? FileManager.default.contentsOfDirectory(
            at: objectsURL, includingPropertiesForKeys: nil
        ) else {
            bumpRunsCompleted()
            return
        }

        for item in contents {
            if Task.isCancelled { return }   // bailed — runsCompleted NOT bumped
            bumpItemsConsidered()
            let hash = item.lastPathComponent
            if !referencedHashes.contains(hash) {
                try? FileManager.default.removeItem(at: item)
                bumpItemsRemoved()
            }
        }
        bumpRunsCompleted()
    }

    // MARK: - Test-only counters

    /// Test-only. Number of times `evictUnreferencedObjects()` started.
    var evictionRunsStarted: Int {
        os_unfair_lock_lock(&_counterLock); defer { os_unfair_lock_unlock(&_counterLock) }
        return _runsStarted
    }
    /// Test-only. Number of times `evictUnreferencedObjects()` ran to completion
    /// (returned without being cancelled).
    var evictionRunsCompleted: Int {
        os_unfair_lock_lock(&_counterLock); defer { os_unfair_lock_unlock(&_counterLock) }
        return _runsCompleted
    }
    /// Test-only. Number of directory entries inspected across all runs.
    var evictionItemsConsidered: Int {
        os_unfair_lock_lock(&_counterLock); defer { os_unfair_lock_unlock(&_counterLock) }
        return _itemsConsidered
    }
    /// Test-only. Number of files removed across all runs.
    var evictionItemsRemoved: Int {
        os_unfair_lock_lock(&_counterLock); defer { os_unfair_lock_unlock(&_counterLock) }
        return _itemsRemoved
    }
    /// Test-only. Resets all eviction counters.
    func resetEvictionCounters() {
        os_unfair_lock_lock(&_counterLock); defer { os_unfair_lock_unlock(&_counterLock) }
        _runsStarted = 0
        _runsCompleted = 0
        _itemsConsidered = 0
        _itemsRemoved = 0
    }

    private func bumpRunsStarted() {
        os_unfair_lock_lock(&_counterLock); defer { os_unfair_lock_unlock(&_counterLock) }
        _runsStarted &+= 1
    }
    private func bumpRunsCompleted() {
        os_unfair_lock_lock(&_counterLock); defer { os_unfair_lock_unlock(&_counterLock) }
        _runsCompleted &+= 1
    }
    private func bumpItemsConsidered() {
        os_unfair_lock_lock(&_counterLock); defer { os_unfair_lock_unlock(&_counterLock) }
        _itemsConsidered &+= 1
    }
    private func bumpItemsRemoved() {
        os_unfair_lock_lock(&_counterLock); defer { os_unfair_lock_unlock(&_counterLock) }
        _itemsRemoved &+= 1
    }

    // MARK: - Manifest

    /// Writes `data` directly into the manifest slot. No hash check — this is the
    /// top-level manifest whose sha isn't itself referenced anywhere.
    func writeManifest(_ data: Data) throws {
        try data.write(to: manifestURL, options: .atomic)
    }

    /// Reads the cached manifest bytes if one was written.
    func readManifest() -> Data? {
        try? Data(contentsOf: manifestURL)
    }
}

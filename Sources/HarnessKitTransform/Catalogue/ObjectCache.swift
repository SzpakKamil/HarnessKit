import Foundation
import CryptoKit
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

    // MARK: - Download + verify

    /// Downloads the file at `remoteURL`, verifies its sha256 matches `expectedSHA256`,
    /// and atomically places it at `objects/<sha256>`. Retries up to `maxRetries` times
    /// with exponential backoff on failure. Returns the final on-disk URL.
    func download(from remoteURL: URL, expectedSHA256: String, maxRetries: Int = 2) async throws -> URL {
        var lastError: Error?
        for attempt in 0...maxRetries {
            if attempt > 0 {
                guard !Task.isCancelled else { throw CancellationError() }
                let delaySeconds = pow(2.0, Double(attempt - 1))
                if #available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *) {
                    try await Task.sleep(for: .seconds(delaySeconds))
                } else {
                    try await Task.sleep(nanoseconds: UInt64(delaySeconds * 1_000_000_000))
                }
            }
            do {
                return try await performDownload(from: remoteURL, expectedSHA256: expectedSHA256)
            } catch {
                lastError = error
            }
        }
        throw lastError!
    }

    private func performDownload(from remoteURL: URL, expectedSHA256: String) async throws -> URL {
        // Stream the response body straight to a temp file so the full
        // payload never materializes in RAM — bezel PNGs run 5-50 MB
        // each and a parallel download fleet would otherwise pin
        // `N × payload` memory while downloads complete.
        //
        // Leak safety: `downloadedTempURL` MUST be moved or unlinked
        // before this function returns or throws. The `defer` below
        // unlinks it unless we've already handed it off to
        // `moveItem(at:to:)` (tracked via `movedToFinal`).
        let downloadedTempURL = try await downloadToTempFile(from: remoteURL)
        var movedToFinal = false
        defer {
            if !movedToFinal {
                try? FileManager.default.removeItem(at: downloadedTempURL)
            }
        }

        let actual = try ObjectCache.hashFile(at: downloadedTempURL)
        guard actual == expectedSHA256 else {
            throw NSError(
                domain: "HarnessKit.ObjectCache",
                code: -10,
                userInfo: [NSLocalizedDescriptionKey:
                    "SHA256 mismatch for \(remoteURL.lastPathComponent): expected \(expectedSHA256), got \(actual)"]
            )
        }

        let finalURL = objectsURL.appendingPathComponent(expectedSHA256)
        let stagingURL = finalURL.appendingPathExtension("tmp-\(UUID().uuidString)")
        // Move the OS-provided temp file into our cache's `objects/` so
        // the final `moveItem` stays same-volume (and therefore atomic +
        // cheap). The interim `stagingURL` is still inside `objectsURL`.
        try FileManager.default.moveItem(at: downloadedTempURL, to: stagingURL)
        movedToFinal = true  // OS temp file is now gone; staging owns the bytes

        // Second move: staging → final. If `finalURL` already exists
        // (another concurrent download won the race), overwrite it —
        // we've already verified the hash matches.
        if FileManager.default.fileExists(atPath: finalURL.path) {
            try? FileManager.default.removeItem(at: finalURL)
        }
        do {
            try FileManager.default.moveItem(at: stagingURL, to: finalURL)
        } catch {
            // Staging file is orphaned — unlink explicitly (defer above
            // is keyed on downloadedTempURL, not staging).
            try? FileManager.default.removeItem(at: stagingURL)
            throw error
        }
        return finalURL
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

    // MARK: - Helpers

    static func hash(data: Data) -> String {
        hexEncode(SHA256.hash(data: data))
    }

    /// Streaming SHA256 over an on-disk file. Reads 64 KB at a time so
    /// even a 500 MB bezel stays at ~64 KB steady-state RAM during the
    /// hash step — previously the whole file was slurped into Data and
    /// hashed in-memory.
    ///
    /// Leak safety: `FileHandle` closed via `defer` regardless of
    /// whether reads throw or end cleanly.
    static func hashFile(at url: URL) throws -> String {
        let handle = try FileHandle(forReadingFrom: url)
        defer { try? handle.close() }

        var hasher = SHA256()
        let chunkSize = 64 * 1024
        while true {
            let chunk: Data
            if #available(macOS 10.15.4, iOS 13.4, tvOS 13.4, watchOS 6.2, *) {
                chunk = try handle.read(upToCount: chunkSize) ?? Data()
            } else {
                chunk = handle.readData(ofLength: chunkSize)
            }
            if chunk.isEmpty { break }
            hasher.update(data: chunk)
        }
        return hexEncode(hasher.finalize())
    }

    /// Encodes a `SHA256.Digest` (or any `Sequence<UInt8>`) as lowercase hex
    /// using a static 256-entry lookup table. Replaces the previous
    /// `.map { String(format: "%02x", $0) }.joined()` chain which allocated
    /// one small String per byte (32 per hash) plus the joined Array — hot
    /// path because it runs once per download.
    static func hexEncode<S: Sequence>(_ bytes: S) -> String where S.Element == UInt8 {
        // Two characters per byte; reserve to avoid COW growth.
        var out = ""
        if let count = (bytes as? any Collection)?.count {
            out.reserveCapacity(count * 2)
        }
        for byte in bytes {
            out.append(hexTable[Int(byte)])
        }
        return out
    }
}

/// Precomputed lowercase-hex table: `hexTable[i] == String(format: "%02x", i)`.
/// Static constant so we pay the 256 × 2-char init cost exactly once per
/// process rather than per-byte-per-hash.
private let hexTable: [String] = (0...255).map { byte in
    String(format: "%02x", byte)
}

// MARK: - URLSession wrapper

/// Fetches data from a URL. Uses native async `URLSession.data(from:)` on macOS 12+ / iOS 15+,
/// falls back to a continuation-based wrapper on older OS versions.
private func fetchData(_ url: URL) async throws -> Data {
    if #available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *) {
        let (data, response) = try await URLSession.shared.data(from: url)
        if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            throw NSError(
                domain: "HarnessKit.ObjectCache",
                code: http.statusCode,
                userInfo: [NSLocalizedDescriptionKey: "HTTP \(http.statusCode) for \(url.absoluteString)"]
            )
        }
        return data
    } else {
        return try await withCheckedThrowingContinuation { cont in
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                if let error {
                    cont.resume(throwing: error)
                    return
                }
                if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
                    cont.resume(throwing: NSError(
                        domain: "HarnessKit.ObjectCache",
                        code: http.statusCode,
                        userInfo: [NSLocalizedDescriptionKey: "HTTP \(http.statusCode) for \(url.absoluteString)"]
                    ))
                    return
                }
                guard let data else {
                    cont.resume(throwing: URLError(.badServerResponse))
                    return
                }
                cont.resume(returning: data)
            }
            task.resume()
        }
    }
}

/// Exposed to `HarnessKitCatalogue` so it can fetch the manifest without going
/// through the content-addressed path (the manifest has no pre-known sha).
func harnessKitFetchData(_ url: URL) async throws -> Data {
    try await fetchData(url)
}

/// Downloads the response body to an OS-provided temp file without
/// buffering the payload in memory. Returns the temp file URL — callers
/// own the bytes and MUST move or delete the file.
///
/// On macOS 12+/iOS 15+, `URLSession.download(from:)` streams straight
/// to disk. On older systems, wraps `URLSessionDownloadTask`'s callback
/// in a checked continuation, with a guard (`resumed` flag held by
/// reference class) so the continuation never resumes twice even if
/// URLSession's callback fires in the wrong order (which it won't in
/// practice, but the continuation contract requires exactly-one).
///
/// Leak safety: on HTTP error the OS temp file is unlinked before
/// throwing so no orphan stays in `/tmp`.
private func downloadToTempFile(from url: URL) async throws -> URL {
    if #available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *) {
        let (tempURL, response) = try await URLSession.shared.download(from: url)
        if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            try? FileManager.default.removeItem(at: tempURL)
            throw NSError(
                domain: "HarnessKit.ObjectCache",
                code: http.statusCode,
                userInfo: [NSLocalizedDescriptionKey: "HTTP \(http.statusCode) for \(url.absoluteString)"]
            )
        }
        return tempURL
    } else {
        // Continuation-based fallback. `ResumeGate` prevents double-resume
        // if URLSession ever invokes the callback path twice under load
        // (defensive — URLSession's contract says once, but a two-call
        // bug would manifest as a process crash that's annoying to debug
        // in the field).
        final class ResumeGate: @unchecked Sendable {
            private var _lock = os_unfair_lock_s()
            private var resumed = false
            func claim() -> Bool {
                os_unfair_lock_lock(&_lock); defer { os_unfair_lock_unlock(&_lock) }
                if resumed { return false }
                resumed = true
                return true
            }
        }
        let gate = ResumeGate()
        return try await withCheckedThrowingContinuation { cont in
            let task = URLSession.shared.downloadTask(with: url) { tempURL, response, error in
                guard gate.claim() else { return }
                if let error {
                    cont.resume(throwing: error)
                    return
                }
                if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
                    if let tempURL { try? FileManager.default.removeItem(at: tempURL) }
                    cont.resume(throwing: NSError(
                        domain: "HarnessKit.ObjectCache",
                        code: http.statusCode,
                        userInfo: [NSLocalizedDescriptionKey: "HTTP \(http.statusCode) for \(url.absoluteString)"]
                    ))
                    return
                }
                guard let tempURL else {
                    cont.resume(throwing: URLError(.badServerResponse))
                    return
                }
                // The downloadTask's callback returns synchronously and
                // URLSession deletes the temp file once this closure exits.
                // Copy it to a location we control before resuming.
                let ourTemp = FileManager.default.temporaryDirectory
                    .appendingPathComponent("HarnessKit-dl-\(UUID().uuidString)")
                do {
                    try FileManager.default.moveItem(at: tempURL, to: ourTemp)
                    cont.resume(returning: ourTemp)
                } catch {
                    cont.resume(throwing: error)
                }
            }
            task.resume()
        }
    }
}

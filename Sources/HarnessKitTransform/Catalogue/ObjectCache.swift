//
//  ObjectCache.swift
//  HarnessKitTransform
//

import Foundation
import CryptoKit

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

    static let shared = ObjectCache()

    let rootURL: URL
    let objectsURL: URL
    let manifestURL: URL

    private init() {
        // In a sandboxed app (App Store builds) this resolves inside the app's
        // sandbox container — e.g. `~/Library/Containers/<bundle-id>/Data/Library/Caches/HarnessKit`.
        // In a non-sandboxed app it's `~/Library/Caches/HarnessKit`. Either way the
        // directory is private to the app and OS-evictable under disk pressure, which
        // is exactly what we want for re-downloadable bulk assets (the manifest lets
        // us reconstruct everything). Not backed up by iCloud, so it won't bloat
        // users' backups.
        let fm = FileManager.default
        let caches = (try? fm.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true))
            ?? URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("Library/Caches", isDirectory: true)
        let root = caches.appendingPathComponent("HarnessKit", isDirectory: true)
        self.rootURL = root
        self.objectsURL = root.appendingPathComponent("objects", isDirectory: true)
        self.manifestURL = root.appendingPathComponent("manifest.json")
        try? fm.createDirectory(at: objectsURL, withIntermediateDirectories: true)
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
                return try await _download(from: remoteURL, expectedSHA256: expectedSHA256)
            } catch {
                lastError = error
            }
        }
        throw lastError!
    }

    private func _download(from remoteURL: URL, expectedSHA256: String) async throws -> URL {
        let data = try await fetchData(remoteURL)
        let actual = ObjectCache.hash(data: data)
        guard actual == expectedSHA256 else {
            throw NSError(
                domain: "HarnessKit.ObjectCache",
                code: -10,
                userInfo: [NSLocalizedDescriptionKey:
                    "SHA256 mismatch for \(remoteURL.lastPathComponent): expected \(expectedSHA256), got \(actual)"]
            )
        }
        let finalURL = objectsURL.appendingPathComponent(expectedSHA256)
        let tempURL = finalURL.appendingPathExtension("tmp-\(UUID().uuidString)")
        try data.write(to: tempURL, options: .atomic)
        if FileManager.default.fileExists(atPath: finalURL.path) {
            try? FileManager.default.removeItem(at: finalURL)
        }
        try FileManager.default.moveItem(at: tempURL, to: finalURL)
        return finalURL
    }

    // MARK: - Eviction

    /// Removes cached objects not referenced by the current manifest.
    /// Call after `refresh()` to free space from old bezels.
    func evictUnreferencedObjects() {
        guard let manifest = CatalogueStore.shared.manifest else { return }
        let referencedHashes = Set(manifest.files.values.map(\.sha256))

        guard let contents = try? FileManager.default.contentsOfDirectory(
            at: objectsURL, includingPropertiesForKeys: nil
        ) else { return }

        for item in contents {
            let hash = item.lastPathComponent
            if !referencedHashes.contains(hash) {
                try? FileManager.default.removeItem(at: item)
            }
        }
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
        SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
    }
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

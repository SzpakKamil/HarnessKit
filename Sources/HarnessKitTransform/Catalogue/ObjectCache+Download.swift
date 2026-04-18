import Foundation
import os.lock

extension ObjectCache {

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

    func performDownload(from remoteURL: URL, expectedSHA256: String) async throws -> URL {
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

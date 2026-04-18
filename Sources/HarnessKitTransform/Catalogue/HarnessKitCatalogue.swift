import Foundation
import HarnessKitScreenshots

/// The public entry point for HarnessKit's remote catalogue of bezels and device
/// JSONs hosted on Cloudflare R2.
///
/// Typical usage (from a tester / CI driver, on app launch or before a capture batch):
///
/// ```swift
/// try await HarnessKitCatalogue.shared.refresh()               // fetch manifest
/// try await HarnessKitCatalogue.shared.prefetch(for: config)   // download needed bezels
/// // now call processScreenshotMacOS / processScreenshotIOS / … synchronously.
/// ```
///
/// If the network is unreachable, `refresh()` is a no-op and descriptor lookups
/// transparently fall back to the bundled baseline that ships with the SPM package.
public actor HarnessKitCatalogue {

    public static let shared = HarnessKitCatalogue()

    /// Base URL for remote assets. Defaults to the production R2 custom domain.
    /// Assign before the first call to ``refresh()`` to point at staging or a
    /// local mirror. Thread-safe — backed by an `os_unfair_lock` so concurrent
    /// reads and writes are race-free.
    public nonisolated static var baseURL: URL {
        get { BaseURLConfig.shared.url }
        set { BaseURLConfig.shared.setURL(newValue) }
    }

    /// In-flight eviction handle. `refresh()` cancels and replaces it; `evictStaleCache()`
    /// awaits it (single-flight coalescing). `nil` when no eviction has run yet.
    private var evictionTask: Task<Void, Never>?

    private init() {
        // If we wrote a manifest in a previous session, rehydrate it so descriptor
        // lookups hit the cache without needing a network refresh first.
        if let data = ObjectCache.shared.readManifest(),
           let manifest = try? JSONDecoder().decode(Manifest.self, from: data),
           manifest.schemaVersion <= kHarnessKitManifestSchemaVersion {
            CatalogueStore.shared.setManifest(manifest)
        }
    }

    // MARK: - Refresh

    /// Fetches `manifest.json` from `baseURL`, validates its schemaVersion, and
    /// installs it as the current in-memory manifest. Downloads the catalogue JSONs
    /// (`catalogue/*.json`) so descriptor loaders can read them synchronously later.
    ///
    /// This does **not** download any bezel PNGs — call `prefetch(for:)` for that.
    public func refresh() async throws {
        let manifestURL = HarnessKitCatalogue.baseURL.appendingPathComponent(RemotePath.manifest)
        let data: Data
        do {
            data = try await harnessKitFetchData(manifestURL)
        } catch {
            // Offline / transient failure: keep whatever we had.
            throw error
        }
        let manifest = try JSONDecoder().decode(Manifest.self, from: data)
        guard manifest.schemaVersion <= kHarnessKitManifestSchemaVersion else {
            throw NSError(
                domain: "HarnessKit.Catalogue",
                code: -20,
                userInfo: [NSLocalizedDescriptionKey:
                    "Remote manifest schemaVersion \(manifest.schemaVersion) is newer than client \(kHarnessKitManifestSchemaVersion); ignoring."]
            )
        }

        try ObjectCache.shared.writeManifest(data)
        CatalogueStore.shared.setManifest(manifest)

        // Proactively fetch catalogue JSONs — they're tiny and needed for every descriptor call.
        try await downloadCatalogueJSONs(manifest: manifest)

        // Fire-and-forget eviction. Cancel any in-flight prior run so its
        // (now stale) manifest snapshot can't accidentally delete files the
        // current refresh just downloaded. The detached task reads the
        // freshly-installed manifest inside its body. `Task.detached` is the
        // right primitive on Swift 6.0 — `Task { … }` would inherit actor
        // isolation and serialize behind subsequent calls, and `@concurrent`
        // is 6.2+. Cancellation lands at the next item-iteration boundary
        // inside `evictUnreferencedObjects`.
        evictionTask?.cancel()
        evictionTask = Task.detached(priority: .utility) {
            ObjectCache.shared.evictUnreferencedObjects()
        }
    }

    // MARK: - Prefetch

    /// Downloads every bezel referenced — directly or transitively — by any
    /// `VersionedBezel` in `config`. Files already present in the object cache are
    /// skipped. Safe to call repeatedly.
    public func prefetch(for config: ScreenshotConfig) async throws {
        guard let manifest = CatalogueStore.shared.manifest else {
            // No manifest yet (cold start before refresh). Caller falls back to bundle.
            return
        }

        var needed: Set<String> = []

        // Mac: every bezel file matching the (size, color) cell for each VersionedBezel.
        for bezel in config.macBezel {
            needed.formUnion(macBezelRelativePaths(for: bezel, in: manifest))
        }
        // Phone / TV / Vision: deterministic `device*{id}^color*{color}.png` path.
        for bezel in config.phoneBezel {
            needed.insert(RemotePath.phoneBezelPrefix + "device*\(bezel.deviceID)^color*\(bezel.color).png")
        }
        for bezel in config.tvBezel {
            needed.formUnion(tvBezelRelativePaths(for: bezel, in: manifest))
        }
        // Pad: processor-set bezels — scan manifest like Mac.
        for bezel in config.padBezel {
            needed.formUnion(padBezelRelativePaths(for: bezel, in: manifest))
        }
        // Watch: `device*AppleWatch^series*…^size*…^material*…^color*…^band*….png`.
        for bezel in config.watchBezel {
            needed.formUnion(watchBezelRelativePaths(for: bezel, in: manifest))
        }
        // Vision: deterministic `device*{id}^color*{color}.png` path.
        for bezel in config.visionBezel {
            needed.insert(RemotePath.visionBezelPrefix + "device*\(bezel.deviceID)^color*\(bezel.color).png")
        }

        try await downloadPaths(needed, manifest: manifest)
    }

    /// Downloads every file in the current manifest. Used by Tester / CI to warm
    /// the whole cache in one shot.
    public func prefetchAll() async throws {
        guard let manifest = CatalogueStore.shared.manifest else { return }
        try await downloadPaths(Set(manifest.files.keys), manifest: manifest)
    }

    /// Forces all generation-keyed caches (device descriptors, bezel indexes) to
    /// rebuild on next access. Call after `prefetch` when you need the freshly
    /// downloaded bezels to be visible to synchronous `bezelImage()` lookups.
    public func invalidateCaches() {
        CatalogueStore.shared.invalidateCaches()
        BezelImageCache.shared.clear()
        CIImageCache.clear()
        ContinuousPathCache.clear()
        TextRenderCache.clear()
    }

    /// Removes cached objects not referenced by the current manifest.
    /// Safe to call at any time — no-op if no manifest is loaded.
    ///
    /// Single-flight: if an eviction kicked off by `refresh()` (or a previous
    /// `evictStaleCache()` call) is still running, this call awaits its
    /// completion instead of starting a duplicate. Eviction is idempotent
    /// against the current manifest, so coalescing is always correct.
    public func evictStaleCache() async {
        if let task = evictionTask {
            await task.value
            return
        }
        let task = Task.detached(priority: .utility) {
            ObjectCache.shared.evictUnreferencedObjects()
        }
        evictionTask = task
        await task.value
    }

    // MARK: - Private

    private func downloadCatalogueJSONs(manifest: Manifest) async throws {
        let bucket = manifest.filesByPrefix[RemotePath.cataloguePrefix] ?? []
        try await downloadPaths(bucket, manifest: manifest)
    }

    /// Downloads any of `paths` not yet in the cache. Bounded to `bulkDownloadConcurrency`
    /// simultaneous HTTP requests to exploit URLSession's connection pool without
    /// hammering the origin. Throws `TransformError.notInManifest` if any requested
    /// paths are missing from the manifest.
    ///
    /// Leak safety: `withThrowingTaskGroup` auto-cancels siblings on throw and
    /// waits for them before rethrowing — no task outlives this function. Inner
    /// `try Task.checkCancellation()` in each child honors outer-task cancellation
    /// so a cancelled refresh() unblocks immediately instead of waiting for the
    /// whole batch.
    private func downloadPaths(_ paths: Set<String>, manifest: Manifest) async throws {
        // Partition paths into missing-from-manifest (fail later) vs
        // already-cached (skip) vs needs-download. This pre-pass is sync
        // and cheap — puts the task group body exclusively on network I/O.
        var missingFromManifest: [String] = []
        var needsDownload: [(path: String, url: URL, sha256: String)] = []
        for path in paths {
            guard let entry = manifest.files[path] else {
                missingFromManifest.append(path)
                continue
            }
            if ObjectCache.shared.url(forSHA256: entry.sha256, expectedSize: entry.size) != nil {
                continue  // already cached
            }
            guard let remoteURL = RemotePath.url(base: HarnessKitCatalogue.baseURL, relativePath: path) else {
                continue  // malformed path — silently skip, matches prior behavior
            }
            needsDownload.append((path, remoteURL, entry.sha256))
        }

        if !needsDownload.isEmpty {
            let bounded = max(1, min(Self.bulkDownloadConcurrency, needsDownload.count))
            var iterator = needsDownload.makeIterator()
            try await withThrowingTaskGroup(of: Void.self) { group in
                // Seed: kick off `bounded` tasks so throttle invariant is
                // structural — only `bounded` tasks ever exist concurrently.
                // Same seed-and-drain pattern used by `transformScreenshots`.
                for _ in 0..<bounded {
                    guard let job = iterator.next() else { break }
                    group.addTask {
                        try Task.checkCancellation()
                        _ = try await ObjectCache.shared.download(
                            from: job.url, expectedSHA256: job.sha256
                        )
                    }
                }
                // Drain: consume one completion, add one task.
                while try await group.next() != nil {
                    guard let job = iterator.next() else { continue }
                    group.addTask {
                        try Task.checkCancellation()
                        _ = try await ObjectCache.shared.download(
                            from: job.url, expectedSHA256: job.sha256
                        )
                    }
                }
            }
        }

        if !missingFromManifest.isEmpty {
            throw TransformError.notInManifest(paths: missingFromManifest.sorted())
        }
    }

    /// Max parallel HTTP downloads during bulk prefetch. URLSession's default
    /// connection pool is per-host and plenty for 4 concurrent fetches against
    /// a single R2 origin. Higher values risk throttling; lower values leave
    /// the pipeline underutilized.
    private static let bulkDownloadConcurrency = 4
}

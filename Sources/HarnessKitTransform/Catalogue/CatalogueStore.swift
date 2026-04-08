//
//  CatalogueStore.swift
//  HarnessKitTransform
//

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
final class CatalogueStore: @unchecked Sendable {

    static let shared = CatalogueStore()

    private let lock = NSLock()
    private var _manifest: Manifest?
    private var _generation: Int = 0

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
    func json(forCatalogueName name: String) -> Data? {
        let relativePath = RemotePath.cataloguePrefix + "\(name).json"
        if let entry = manifest?.files[relativePath],
           let url = ObjectCache.shared.url(forSHA256: entry.sha256, expectedSize: entry.size),
           let data = try? Data(contentsOf: url) {
            return data
        }
        guard
            let url = Bundle.module.url(forResource: name, withExtension: "json"),
            let data = try? Data(contentsOf: url)
        else { return nil }
        return data
    }

    /// Returns the on-disk URL for a bezel whose R2 relative path is `relativePath`.
    /// Cache-first; returns `nil` if not cached (caller falls back to bundle).
    func cachedBezelURL(relativePath: String) -> URL? {
        guard let entry = manifest?.files[relativePath] else { return nil }
        return ObjectCache.shared.url(forSHA256: entry.sha256, expectedSize: entry.size)
    }

    /// Every relative path in the current manifest with the given prefix, e.g. `"bezels/mac/"`.
    func filePaths(withPrefix prefix: String) -> [String] {
        guard let manifest else { return [] }
        return manifest.files.keys.filter { $0.hasPrefix(prefix) }
    }
}

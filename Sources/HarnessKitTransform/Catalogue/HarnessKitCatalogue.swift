//
//  HarnessKitCatalogue.swift
//  HarnessKitTransform
//

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
    public nonisolated(unsafe) static var baseURL: URL = URL(string: "https://harnesskitassets.kamilszpak.com")!

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

        // Remove cached objects from previous manifests to free disk space.
        ObjectCache.shared.evictUnreferencedObjects()
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
    }

    /// Removes cached objects not referenced by the current manifest.
    /// Safe to call at any time — no-op if no manifest is loaded.
    public func evictStaleCache() {
        ObjectCache.shared.evictUnreferencedObjects()
    }

    // MARK: - Private

    private func downloadCatalogueJSONs(manifest: Manifest) async throws {
        let paths = manifest.files.keys.filter { $0.hasPrefix(RemotePath.cataloguePrefix) }
        try await downloadPaths(Set(paths), manifest: manifest)
    }

    /// Downloads any of `paths` not yet in the cache.
    /// Throws `TransformError.notInManifest` if any requested paths are missing from the manifest.
    private func downloadPaths(_ paths: Set<String>, manifest: Manifest) async throws {
        var missingFromManifest: [String] = []
        for path in paths {
            try Task.checkCancellation()
            guard let entry = manifest.files[path] else {
                missingFromManifest.append(path)
                continue
            }
            if ObjectCache.shared.url(forSHA256: entry.sha256, expectedSize: entry.size) != nil {
                continue
            }
            guard let remoteURL = RemotePath.url(base: HarnessKitCatalogue.baseURL, relativePath: path) else {
                continue
            }
            _ = try await ObjectCache.shared.download(from: remoteURL, expectedSHA256: entry.sha256)
        }
        if !missingFromManifest.isEmpty {
            throw TransformError.notInManifest(paths: missingFromManifest.sorted())
        }
    }

    /// Every manifest path under `bezels/mac/` whose parsed `(size, color)` matches
    /// this `VersionedBezel`. The screenshot-time selector later filters by
    /// `(os, wallpaper, appearance, model)` — we prefetch the union.
    private func macBezelRelativePaths(for bezel: VersionedBezel, in manifest: Manifest) -> Set<String> {
        // Extract size from deviceID. Handles both M-series ("MacbookPro14M4") and
        // A-series ("MacbookNeo13A18Pro").
        let size: String
        if let mRange = bezel.deviceID.range(of: #"\d+M\d+$"#, options: .regularExpression) {
            size = String(bezel.deviceID[mRange].prefix { $0.isNumber })
        } else if let aRange = bezel.deviceID.range(of: #"\d+A\d+[A-Za-z]*$"#, options: .regularExpression) {
            size = String(bezel.deviceID[aRange].prefix { $0.isNumber })
        } else {
            return []
        }

        var result: Set<String> = []
        for path in manifest.files.keys where path.hasPrefix(RemotePath.macBezelPrefix) {
            // Parse enough of the filename to match size + color.
            let name = String(path.dropFirst(RemotePath.macBezelPrefix.count))
            let fields = parseKeyedFilename(name)
            if fields["size"] == size && fields["color"] == bezel.color {
                result.insert(path)
            }
        }
        return result
    }

    /// Every manifest path under `bezels/pad/` matching the (device family, processor, color)
    /// derived from the `VersionedBezel` deviceID (e.g. `"iPadAir11M4"` → family `"iPadAir11"`, processor `"M4"`).
    private func padBezelRelativePaths(for bezel: VersionedBezel, in manifest: Manifest) -> Set<String> {
        let (family, processor) = parsePadDeviceID(bezel.deviceID)
        var result: Set<String> = []
        for path in manifest.files.keys where path.hasPrefix(RemotePath.padBezelPrefix) {
            let name = String(path.dropFirst(RemotePath.padBezelPrefix.count))
            let fields = parseKeyedFilename(name)
            guard fields["device"] == family && fields["color"] == bezel.color else { continue }
            if let processor {
                let procs = Set((fields["processors"] ?? "").split(separator: "+").map(String.init))
                guard procs.contains(processor) else { continue }
            }
            result.insert(path)
        }
        return result
    }

    /// Splits `"iPadAir11M4"` → `("iPadAir11", "M4")`, `"iPad9thGen"` → `("iPad9thGen", nil)`.
    private func parsePadDeviceID(_ id: String) -> (family: String, processor: String?) {
        guard let range = id.range(of: #"(M\d+|A\d+[A-Za-z]*)$"#, options: .regularExpression) else {
            return (id, nil)
        }
        return (String(id[id.startIndex..<range.lowerBound]), String(id[range]))
    }

    /// Every manifest path under `bezels/watch/` matching the (series, size, material, color, band)
    /// derived from the `VersionedBezel` deviceID.
    private func watchBezelRelativePaths(for bezel: VersionedBezel, in manifest: Manifest) -> Set<String> {
        let stripped = bezel.deviceID.hasPrefix("AppleWatch")
            ? String(bezel.deviceID.dropFirst("AppleWatch".count))
            : bezel.deviceID
        guard let mmRange = stripped.range(of: "mm") else { return [] }
        let beforeMM = String(stripped[stripped.startIndex..<mmRange.lowerBound])
        let material = String(stripped[mmRange.upperBound...])
        // All Apple Watch sizes are exactly 2 digits (41, 42, 44, 45, 46, 49).
        let size = String(beforeMM.suffix(2))
        let series = String(beforeMM.dropLast(2))

        var result: Set<String> = []
        for path in manifest.files.keys where path.hasPrefix(RemotePath.watchBezelPrefix) {
            let name = String(path.dropFirst(RemotePath.watchBezelPrefix.count))
            let fields = parseKeyedFilename(name)
            if fields["series"]   == series
                && fields["size"]     == size
                && fields["material"] == material
                && fields["color"]    == bezel.color
                && fields["band"]     == bezel.band {
                result.insert(path)
            }
        }
        return result
    }

    /// Every manifest path under `bezels/tv/` matching the device and color.
    /// Handles both simple (`device*AppleTVFrame^color*Default.png`) and generation-set
    /// (`device*AppleTVFrameBox^gens*HD+4K1+4K2+4K3^color*Default.png`) filenames.
    private func tvBezelRelativePaths(for bezel: VersionedBezel, in manifest: Manifest) -> Set<String> {
        var result: Set<String> = []
        for path in manifest.files.keys where path.hasPrefix(RemotePath.tvBezelPrefix) {
            let name = String(path.dropFirst(RemotePath.tvBezelPrefix.count))
            let fields = parseKeyedFilename(name)
            if fields["device"] == bezel.deviceID && fields["color"] == bezel.color {
                result.insert(path)
            }
        }
        return result
    }

}

import Foundation

// MARK: - Shared bezel index builder

/// Builds a bezel index from manifest paths (primary) or bundle PNGs (fallback).
/// Shared by all platform-specific bezel index caches.
func buildBezelIndex<T>(
    prefix: String,
    parse: (String) -> T?,
    resolveURL: (String) -> URL?
) -> [(parsed: T, url: URL)] {
    let manifestPaths = CatalogueStore.shared.filePaths(withPrefix: prefix)
    if !manifestPaths.isEmpty {
        return manifestPaths.compactMap { relativePath in
            let filename = (relativePath as NSString).lastPathComponent
            guard let parsed = parse(filename) else { return nil }
            guard let url = resolveURL(relativePath) else { return nil }
            return (parsed, url)
        }
    }
    guard let urls = Bundle.module.urls(forResourcesWithExtension: "png", subdirectory: nil) else {
        return []
    }
    return urls.compactMap { url in
        guard let parsed = parse(url.lastPathComponent) else { return nil }
        return (parsed, url)
    }
}

/// Resolves a bezel URL from cache first, then bundle fallback.
func defaultBezelURL(relativePath: String) -> URL? {
    if let cached = CatalogueStore.shared.cachedBezelURL(relativePath: relativePath) {
        return cached
    }
    let filename = (relativePath as NSString).lastPathComponent
    let base = (filename as NSString).deletingPathExtension
    return Bundle.module.url(forResource: base, withExtension: "png")
}

// MARK: - Parsed pad bezel filename (processor-set convention)

/// A pad bezel filename parsed from the `key*value^key*value` convention.
/// Used to resolve requests for iPad descriptors whose `id` encodes a chip suffix.
///
/// Example file: `device*iPadAir11^processors*M2+M3+M4^color*Blue.png`
struct ParsedPadBezelName {
    let device: String
    let processors: Set<String>
    let color: String

    static func parse(_ filename: String) -> ParsedPadBezelName? {
        let fields = parseKeyedFilename(filename)
        guard
            let device   = fields["device"],
            let procsRaw = fields["processors"],
            let color    = fields["color"]
        else { return nil }
        return ParsedPadBezelName(
            device:     device,
            processors: Set(procsRaw.split(separator: "+").map(String.init)),
            color:      color
        )
    }

    static var index: [(parsed: ParsedPadBezelName, url: URL)] {
        padIndexCache.current()
    }
}

private let padIndexCache = GenerationCache {
    buildBezelIndex(prefix: RemotePath.padBezelPrefix, parse: ParsedPadBezelName.parse, resolveURL: defaultBezelURL)
}

// MARK: - O(1) lookup tables (Pad)

/// Hashable lookup key. `processor` is left empty on the no-processor path
/// (`byDeviceColor`) so the same struct can back both dicts.
struct PadBezelKey: Hashable {
    let device: String
    let processor: String
    let color: String
}

/// Precomputed dicts layered on top of `padIndexCache`. Replaces the
/// `.first { ... }` linear scans in `DeviceDescriptor.bezelImage` with
/// O(1) probes. `first-wins` matches the scan's iteration semantics.
struct PadBezelTables: Sendable {
    let byProcessor: [PadBezelKey: URL]
    let byDeviceColor: [PadBezelKey: URL]

    init(from index: [(parsed: ParsedPadBezelName, url: URL)]) {
        var byProc: [PadBezelKey: URL] = [:]
        var byDev: [PadBezelKey: URL] = [:]
        for entry in index {
            for proc in entry.parsed.processors {
                let key = PadBezelKey(device: entry.parsed.device, processor: proc, color: entry.parsed.color)
                if byProc[key] == nil { byProc[key] = entry.url }
            }
            let noProcKey = PadBezelKey(device: entry.parsed.device, processor: "", color: entry.parsed.color)
            if byDev[noProcKey] == nil { byDev[noProcKey] = entry.url }
        }
        self.byProcessor = byProc
        self.byDeviceColor = byDev
    }
}

private let padTablesCache = GenerationCache<PadBezelTables> {
    [PadBezelTables(from: padIndexCache.current())]
}

extension ParsedPadBezelName {
    static var tables: PadBezelTables {
        padTablesCache.current().first ?? PadBezelTables(from: [])
    }
}

// MARK: - Parsed TV bezel filename (generation-set convention)

/// A TV bezel filename parsed from `device*{id}^gens*{g1+g2+...}^color*{color}.png`.
/// Also handles simpler `device*{id}^color*{color}.png` (no gens key).
struct ParsedTVBezelName {
    let device: String
    let generations: Set<String>
    let color: String

    static func parse(_ filename: String) -> ParsedTVBezelName? {
        let fields = parseKeyedFilename(filename)
        guard
            let device = fields["device"],
            let color  = fields["color"]
        else { return nil }
        let gens: Set<String>
        if let gensRaw = fields["gens"] {
            gens = Set(gensRaw.split(separator: "+").map(String.init))
        } else {
            gens = []
        }
        return ParsedTVBezelName(device: device, generations: gens, color: color)
    }

    static var index: [(parsed: ParsedTVBezelName, url: URL)] {
        tvIndexCache.current()
    }
}

private let tvIndexCache = GenerationCache {
    buildBezelIndex(prefix: RemotePath.tvBezelPrefix, parse: ParsedTVBezelName.parse, resolveURL: defaultBezelURL)
}

// MARK: - O(1) lookup tables (TV)

struct TVBezelKey: Hashable {
    let device: String
    let color: String
}

struct TVBezelTables: Sendable {
    let byDeviceColor: [TVBezelKey: URL]

    init(from index: [(parsed: ParsedTVBezelName, url: URL)]) {
        var out: [TVBezelKey: URL] = [:]
        for entry in index {
            let key = TVBezelKey(device: entry.parsed.device, color: entry.parsed.color)
            if out[key] == nil { out[key] = entry.url }
        }
        self.byDeviceColor = out
    }
}

private let tvTablesCache = GenerationCache<TVBezelTables> {
    [TVBezelTables(from: tvIndexCache.current())]
}

extension ParsedTVBezelName {
    static var tables: TVBezelTables {
        tvTablesCache.current().first ?? TVBezelTables(from: [])
    }
}

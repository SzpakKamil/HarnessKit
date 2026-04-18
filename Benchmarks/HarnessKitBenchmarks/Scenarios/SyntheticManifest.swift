//
//  SyntheticManifest.swift
//  HarnessKitBenchmarks
//
//  Synthetic manifest-shaped fixtures for §S5.4 prefix-scan benchmarks.
//  Self-contained — does not import internal `Manifest` / `ManifestFile`
//  symbols. The plan's prefix-bucketing algorithm is replicated here so
//  the benchmark characterizes exactly the same dict operations the
//  production code performs.
//

import Foundation

enum SyntheticManifest {

    struct Entry: Sendable {
        let sha256: String
        let size: Int
    }

    /// Splits ~`entryCount` paths uniformly across the 7 well-known prefixes,
    /// yielding paths shaped like the real manifest (`bezels/<platform>/…` or
    /// `catalogue/…`). Returns the flat `[path: entry]` map.
    static func files(entryCount: Int = 10_000) -> [String: Entry] {
        let prefixes = bezelPrefixes + ["catalogue/"]
        let perPrefix = entryCount / prefixes.count
        var out: [String: Entry] = [:]
        out.reserveCapacity(perPrefix * prefixes.count)
        for (platformIndex, prefix) in prefixes.enumerated() {
            for j in 0..<perPrefix {
                let path = prefix + "device*Synthetic\(platformIndex)_\(j)^color*Default.png"
                out[path] = Entry(sha256: "h\(platformIndex)_\(j)", size: platformIndex * 1000 + j)
            }
        }
        return out
    }

    /// Mirrors `Manifest.groupByPrefix` exactly so the optimized scenario
    /// exercises the same bucket-population shape as production.
    static func groupByPrefix(_ files: [String: Entry]) -> [String: [String: Entry]] {
        var buckets: [String: [String: Entry]] = [:]
        for (path, entry) in files {
            guard let firstSlash = path.firstIndex(of: "/") else { continue }
            let afterFirst = path.index(after: firstSlash)
            if let secondSlash = path[afterFirst...].firstIndex(of: "/") {
                let twoSegmentPrefix = String(path[..<path.index(after: secondSlash)])
                buckets[twoSegmentPrefix, default: [:]][path] = entry
            }
            let topPrefix = String(path[...firstSlash])
            buckets[topPrefix, default: [:]][path] = entry
            buckets["", default: [:]][path] = entry
        }
        return buckets
    }

    static let bezelPrefixes: [String] = [
        "bezels/mac/", "bezels/phone/", "bezels/pad/",
        "bezels/watch/", "bezels/tv/", "bezels/vision/",
    ]

    /// All prefixes a real `prefetch(for:)` would scan in production.
    static let scannedPrefixes: [String] = bezelPrefixes + ["catalogue/"]
}

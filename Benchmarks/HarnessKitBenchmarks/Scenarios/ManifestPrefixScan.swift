//
//  ManifestPrefixScan.swift
//  HarnessKitBenchmarks
//
//  Witnesses §S5.4: prefix-grouped index for `Manifest.files`. One iteration
//  scans all 7 well-known prefixes (mac/phone/pad/watch/tv/vision/catalogue)
//  on a 10 000-entry synthetic manifest. The optimized variant reads from a
//  pre-bucketed `[String: [String: Entry]]`; the unopt control replays the
//  pre-S5.4 `keys.filter { $0.hasPrefix(prefix) }` scan.
//

import Foundation
import HarnessKitTransform

final class ManifestPrefixScan: Scenario, @unchecked Sendable {
    let name = "ManifestPrefixScan-10000"
    let iterations = 1000

    private var byPrefix: [String: [String: SyntheticManifest.Entry]] = [:]

    func prepare() throws {
        let files = SyntheticManifest.files(entryCount: 10_000)
        byPrefix = SyntheticManifest.groupByPrefix(files)
    }

    func run() throws -> PlatformImage? {
        var sink = 0
        for prefix in SyntheticManifest.scannedPrefixes {
            let bucket = byPrefix[prefix] ?? [:]
            sink &+= bucket.count
        }
        precondition(sink > 0)
        return nil
    }

    func teardown() {
        byPrefix = [:]
    }
}

final class ManifestPrefixScanUnopt: Scenario, @unchecked Sendable {
    let name = "ManifestPrefixScanUnopt-10000"
    let iterations = 1000

    private var files: [String: SyntheticManifest.Entry] = [:]

    func prepare() throws {
        files = SyntheticManifest.files(entryCount: 10_000)
    }

    func run() throws -> PlatformImage? {
        var sink = 0
        for prefix in SyntheticManifest.scannedPrefixes {
            let matched = files.keys.filter { $0.hasPrefix(prefix) }
            sink &+= matched.count
        }
        precondition(sink > 0)
        return nil
    }

    func teardown() {
        files = [:]
    }
}

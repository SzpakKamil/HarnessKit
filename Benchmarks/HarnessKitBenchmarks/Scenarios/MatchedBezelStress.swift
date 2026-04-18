//
//  MatchedBezelStress.swift
//  HarnessKitBenchmarks
//
//  Witnesses §S6.1 + §S6.3: `ScreenshotConfig.matchedBezel(for:)` does
//  zero per-call sorts after S6.3 (was 1 after S6.1, 2 before S6.1). One
//  iteration calls matchedBezel ~1000 times across the 5 platform variants
//  with mixed `osVersion` settings (matched and fallback paths).
//

import Foundation
import HarnessKitScreenshots
import HarnessKitTransform

final class MatchedBezelStress: Scenario, @unchecked Sendable {
    let name = "MatchedBezelStress-MixedConfig"
    let iterations = 1000

    private var config: ScreenshotConfig!
    private var screenshots: [Screenshot] = []

    func prepare() throws {
        // Five entries per platform → matchedBezel walks up to 5 sorted
        // candidates per call. Realistic for batch flows that span multiple
        // OS-version cohorts.
        let phone = (16...20).map { v in
            VersionedBezel(minVersion: "\(v).0", deviceID: "iPhone\(v)", color: "Black")
        }
        let pad = (16...20).map { v in
            VersionedBezel(minVersion: "\(v).0", deviceID: "iPad\(v)", color: "Silver")
        }
        let mac = (13...17).map { v in
            VersionedBezel(minVersion: "\(v).0", deviceID: "MacbookPro\(v)", color: "Silver")
        }
        let watch = (10...14).map { v in
            VersionedBezel(minVersion: "\(v).0", deviceID: "AppleWatchS\(v)", color: "Black", band: "Sport")
        }
        let tv = (16...20).map { v in
            VersionedBezel(minVersion: "\(v).0", deviceID: "AppleTV\(v)", color: "Default")
        }
        config = ScreenshotConfig(
            phoneBezel: phone,
            phoneOrientation: .portrait,
            padBezel: pad,
            padOrientation: .landscape,
            watchBezel: watch,
            macBezel: mac,
            tvBezel: tv,
            resolution: .default
        )

        // Mix of versions: some inside ranges, some below all (forces fallback),
        // some without osVersion at all. Each iteration walks through all 9
        // distinct (os, version) pairs once.
        let oses: [TargetOS] = [.iOS, .iPadOS, .macOS, .watchOS, .tvOS]
        let versions: [String?] = ["18.5", "20.0", "11.0", "5.0", nil]
        var built: [Screenshot] = []
        built.reserveCapacity(oses.count * versions.count)
        for os in oses {
            for v in versions {
                let s = Screenshot(id: "x", appearance: .light, os: os)
                built.append(v.map { s.withOSVersion($0) } ?? s)
            }
        }
        // Multiply so one `run()` does ~1000 matchedBezel calls (close to a
        // mid-size Framely batch's per-render config touch count).
        screenshots = Array(repeating: built, count: 40).flatMap { $0 }
    }

    func run() throws -> PlatformImage? {
        var sink = 0
        for s in screenshots {
            if let m = config.matchedBezel(for: s) {
                sink &+= m.deviceID.count
            }
        }
        precondition(sink > 0)
        return nil
    }

    func teardown() {
        config = nil
        screenshots = []
    }
}

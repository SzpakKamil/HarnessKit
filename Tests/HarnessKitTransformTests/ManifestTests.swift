//
//  ManifestTests.swift
//  HarnessKitTransformTests
//

import XCTest
@testable import HarnessKitTransform

final class ManifestTests: XCTestCase {

    // MARK: - Fixtures

    private func makeFiles() -> [String: ManifestFile] {
        [
            "bezels/mac/device*MacBookPro^size*14^color*Silver.png":   ManifestFile(sha256: "a", size: 1),
            "bezels/mac/device*MacBookPro^size*16^color*SpaceGray.png": ManifestFile(sha256: "b", size: 2),
            "bezels/phone/device*iPhone15Pro^color*Titanium.png":      ManifestFile(sha256: "c", size: 3),
            "bezels/pad/device*iPadAir11^processors*M2+M3^color*Silver.png": ManifestFile(sha256: "d", size: 4),
            "bezels/watch/device*AppleWatch^series*S10.png":           ManifestFile(sha256: "e", size: 5),
            "bezels/tv/device*AppleTVFrame^color*Default.png":          ManifestFile(sha256: "f", size: 6),
            "bezels/vision/device*VisionPro^color*Default.png":         ManifestFile(sha256: "g", size: 7),
            "catalogue/phone_devices.json":                             ManifestFile(sha256: "h", size: 8),
            "catalogue/pad_devices.json":                               ManifestFile(sha256: "i", size: 9),
        ]
    }

    private func makeManifest(_ files: [String: ManifestFile]) -> Manifest {
        Manifest(schemaVersion: 1,
                 catalogueVersion: "test",
                 generatedAt: "2026-04-18",
                 notice: nil,
                 files: files)
    }

    // MARK: - Bucket population

    func testBucketsPopulatedForKnownPrefixes() {
        let m = makeManifest(makeFiles())

        XCTAssertEqual(m.filesByPrefix["bezels/mac/"]?.count, 2)
        XCTAssertEqual(m.filesByPrefix["bezels/phone/"]?.count, 1)
        XCTAssertEqual(m.filesByPrefix["bezels/pad/"]?.count, 1)
        XCTAssertEqual(m.filesByPrefix["bezels/watch/"]?.count, 1)
        XCTAssertEqual(m.filesByPrefix["bezels/tv/"]?.count, 1)
        XCTAssertEqual(m.filesByPrefix["bezels/vision/"]?.count, 1)
        XCTAssertEqual(m.filesByPrefix["catalogue/"]?.count, 2)
        // Top-level "bezels/" rolls up everything under bezels/.
        XCTAssertEqual(m.filesByPrefix["bezels/"]?.count, 7)
        // Sentinel "" matches every path.
        XCTAssertEqual(m.filesByPrefix[""]?.count, m.files.count)
    }

    func testBucketContentsAreCorrectSubsets() {
        let m = makeManifest(makeFiles())
        let macBucket = m.filesByPrefix["bezels/mac/"] ?? []
        for path in macBucket {
            XCTAssertTrue(path.hasPrefix("bezels/mac/"), "found \(path) in mac bucket")
        }
        let cataBucket = m.filesByPrefix["catalogue/"] ?? []
        for path in cataBucket {
            XCTAssertTrue(path.hasPrefix("catalogue/"), "found \(path) in catalogue bucket")
        }
    }

    func testEveryBucketedPathResolvesInFiles() {
        // With keys-only buckets, the invariant is: every path in any bucket
        // maps to a real entry in `m.files`. Prevents stale keys from
        // pointing at nonexistent entries.
        let m = makeManifest(makeFiles())
        for (prefix, bucket) in m.filesByPrefix {
            for path in bucket {
                XCTAssertNotNil(m.files[path],
                    "bucket \(prefix) references path \(path) missing from m.files")
            }
        }
    }

    // MARK: - Edge cases

    func testPathsWithoutSlashAreNotBucketed() {
        // Defensive check: even though manifest.files normally never holds a slash-less
        // path (the producer always namespaces under bezels/* or catalogue/*), the
        // bucketing must not crash and must skip such entries.
        let m = makeManifest(["loose-file.bin": ManifestFile(sha256: "x", size: 1)])
        XCTAssertNil(m.filesByPrefix["loose-file.bin"])
        XCTAssertNil(m.filesByPrefix[""])  // sentinel only added when at least one bucketed path exists
    }

    func testEmptyManifestProducesEmptyIndex() {
        let m = makeManifest([:])
        XCTAssertTrue(m.filesByPrefix.isEmpty)
    }

    // MARK: - Codable round-trip

    func testDecodingPopulatesBuckets() throws {
        let original = makeManifest(makeFiles())
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(Manifest.self, from: data)
        XCTAssertEqual(decoded.filesByPrefix["bezels/mac/"]?.count, 2)
        XCTAssertEqual(decoded.filesByPrefix["catalogue/"]?.count, 2)
        XCTAssertEqual(decoded, original)
    }

    func testEncodedJSONOmitsFilesByPrefix() throws {
        let m = makeManifest(makeFiles())
        let data = try JSONEncoder().encode(m)
        let raw = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
        XCTAssertNil(raw["filesByPrefix"], "filesByPrefix must not be serialized")
        XCTAssertNotNil(raw["files"])
    }

    // MARK: - Equality

    func testEqualityIgnoresDerivedIndex() {
        // Two manifests built from identical files must be equal regardless of the
        // (deterministic but redundant) filesByPrefix bucket dict.
        let a = makeManifest(makeFiles())
        let b = makeManifest(makeFiles())
        XCTAssertEqual(a, b)
    }

    // MARK: - Behavior parity with old hasPrefix scan

    func testBucketParityWithLinearScan() {
        let m = makeManifest(makeFiles())
        let prefixes = ["bezels/mac/", "bezels/phone/", "bezels/pad/",
                        "bezels/watch/", "bezels/tv/", "bezels/vision/", "catalogue/"]
        for prefix in prefixes {
            let oldScan = Set(m.files.keys.filter { $0.hasPrefix(prefix) })
            let newLookup = m.filesByPrefix[prefix] ?? []
            XCTAssertEqual(oldScan, newLookup,
                "bucket \(prefix) must equal the linear hasPrefix scan")
        }
    }
}

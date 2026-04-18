//
//  ScreenshotConfigTests.swift
//  HarnessKitTransformTests
//
//  Covers §S6.1 — `ScreenshotConfig.matchedBezel(for:)` single-sort refactor.
//  Behavior must be identical to the previous "sort twice" implementation:
//  the descending-by-minVersion order is the same in both sort calls, so the
//  fallback's `.first` lands on the same entry the consolidated `sorted.first`
//  returns now.
//

import XCTest
import HarnessKitScreenshots

final class ScreenshotConfigTests: XCTestCase {

    private func phone(_ minVersion: String, _ deviceID: String, maxVersion: String? = nil) -> VersionedBezel {
        VersionedBezel(minVersion: minVersion, maxVersion: maxVersion, deviceID: deviceID, color: "Black")
    }

    private func config(phoneBezel: [VersionedBezel]) -> ScreenshotConfig {
        ScreenshotConfig(
            phoneBezel: phoneBezel,
            phoneOrientation: .portrait,
            padBezel: [],
            padOrientation: .portrait,
            watchBezel: [],
            macBezel: [],
            tvBezel: [],
            resolution: .default
        )
    }

    private func screenshot(os: TargetOS = .iOS, version: String?) -> Screenshot {
        let s = Screenshot(id: "test", appearance: .light, os: os)
        return version.map { s.withOSVersion($0) } ?? s
    }

    // MARK: - Stability (the plan's named test)

    /// `matchedBezel` must be order-independent — feeding the same set of
    /// candidates in different orders must always produce the same result.
    /// Proves the single-sort refactor didn't introduce an ordering bug.
    func testMatchedBezelIsStable() {
        let a = phone("16.0", "iPhoneA")
        let b = phone("17.0", "iPhoneB")
        let c = phone("18.0", "iPhoneC")
        let permutations: [[VersionedBezel]] = [
            [a, b, c], [a, c, b], [b, a, c], [b, c, a], [c, a, b], [c, b, a]
        ]
        for input in permutations {
            // Match inside [17.0, …) → should pick `b` (highest-min ≤ 17.5)
            XCTAssertEqual(
                config(phoneBezel: input).matchedBezel(for: screenshot(version: "17.5"))?.deviceID,
                "iPhoneB"
            )
            // Below all minVersions → fallback to highest-min (`c`)
            XCTAssertEqual(
                config(phoneBezel: input).matchedBezel(for: screenshot(version: "15.0"))?.deviceID,
                "iPhoneC"
            )
            // No osVersion → fallback to highest-min (`c`)
            XCTAssertEqual(
                config(phoneBezel: input).matchedBezel(for: screenshot(version: nil))?.deviceID,
                "iPhoneC"
            )
        }
    }

    // MARK: - Match cases

    func testMatchInsideRangeReturnsThatEntry() {
        // [16.0, 17.0) and [17.0, 18.0) and [18.0, …)
        let bezels = [
            phone("16.0", "iPhoneOld", maxVersion: "17.0"),
            phone("17.0", "iPhoneMid", maxVersion: "18.0"),
            phone("18.0", "iPhoneNew"),
        ]
        let cfg = config(phoneBezel: bezels)
        XCTAssertEqual(cfg.matchedBezel(for: screenshot(version: "16.5"))?.deviceID, "iPhoneOld")
        XCTAssertEqual(cfg.matchedBezel(for: screenshot(version: "17.0"))?.deviceID, "iPhoneMid")
        XCTAssertEqual(cfg.matchedBezel(for: screenshot(version: "17.99"))?.deviceID, "iPhoneMid")
        XCTAssertEqual(cfg.matchedBezel(for: screenshot(version: "18.0"))?.deviceID, "iPhoneNew")
        XCTAssertEqual(cfg.matchedBezel(for: screenshot(version: "26.0"))?.deviceID, "iPhoneNew")
    }

    func testNumericVersionCompareNotLexicographic() {
        // Lexicographic ordering would put "9.0" > "10.0"; numeric .compare must not.
        let bezels = [
            phone("9.0", "iPhoneNine"),
            phone("10.0", "iPhoneTen"),
        ]
        let cfg = config(phoneBezel: bezels)
        // Highest-min descending should be 10.0, then 9.0. v=11 → match 10.0 ("iPhoneTen").
        XCTAssertEqual(cfg.matchedBezel(for: screenshot(version: "11.0"))?.deviceID, "iPhoneTen")
        // No-version fallback → highest-min = 10.0 ("iPhoneTen")
        XCTAssertEqual(cfg.matchedBezel(for: screenshot(version: nil))?.deviceID, "iPhoneTen")
    }

    func testVersionBelowAllFallsBackToHighest() {
        let bezels = [phone("16.0", "iPhoneOld"), phone("17.0", "iPhoneNew")]
        XCTAssertEqual(
            config(phoneBezel: bezels).matchedBezel(for: screenshot(version: "14.0"))?.deviceID,
            "iPhoneNew",
            "no entry's [min, …) covers 14.0 — fallback is highest-min"
        )
    }

    // MARK: - Edge cases

    func testEmptyCandidatesReturnsNil() {
        XCTAssertNil(config(phoneBezel: []).matchedBezel(for: screenshot(version: "17.0")))
    }

    func testVisionOSAlwaysReturnsNil() {
        // Even with a populated phoneBezel, visionOS short-circuits.
        let cfg = config(phoneBezel: [phone("17.0", "iPhoneA")])
        XCTAssertNil(cfg.matchedBezel(for: screenshot(os: .visionOS, version: "1.0")))
    }

    // MARK: - §S6.3 — pre-sorted cache

    /// Decoding via `Codable` rebuilds the pre-sorted cache (the cache isn't
    /// serialized; it's recomputed in `init(from:)`). Same pattern as
    /// `Manifest.filesByPrefix` from §S5.4.
    func testCodableRoundTripPreservesMatchedBezelBehavior() throws {
        let bezels = [
            phone("16.0", "iPhoneOld", maxVersion: "17.0"),
            phone("17.0", "iPhoneMid", maxVersion: "18.0"),
            phone("18.0", "iPhoneNew"),
        ]
        let original = config(phoneBezel: bezels)
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(ScreenshotConfig.self, from: data)
        XCTAssertEqual(decoded, original, "Codable round-trip preserves equality")
        XCTAssertEqual(
            decoded.matchedBezel(for: screenshot(version: "17.5"))?.deviceID,
            "iPhoneMid",
            "decoded config's matchedBezel reads from a freshly-built sorted cache"
        )
    }

    /// Repeat `matchedBezel` calls do not allocate per call — the only sort
    /// happened at init. Indirect assertion via "result is identical when
    /// invoked many times in a row," which would fail under nondeterministic
    /// per-call sort with unstable order.
    func testRepeatedMatchedBezelIsDeterministic() {
        let bezels = [
            phone("16.0", "iPhoneOld"),
            phone("17.0", "iPhoneMid"),
            phone("18.0", "iPhoneNew"),
        ]
        let cfg = config(phoneBezel: bezels)
        for _ in 0..<1000 {
            XCTAssertEqual(cfg.matchedBezel(for: screenshot(version: "17.5"))?.deviceID, "iPhoneMid")
            XCTAssertEqual(cfg.matchedBezel(for: screenshot(version: nil))?.deviceID, "iPhoneNew")
        }
    }

    // MARK: - §S6.2 — screenshotName roundtrip

    /// `screenshotName()` ↔ `Screenshot.fromScreenshotName(_:)` round-trip
    /// must survive every covered metadata variant. Locks the serialization
    /// format so the §S6.2 single-pass refactor doesn't drift the output.
    func testScreenshotNameRoundTrip() {
        let cases: [Screenshot] = [
            Screenshot(id: "basic", appearance: .light, os: .iOS),
            Screenshot(id: "dark", appearance: .dark, os: .iOS, orientation: .landscape),
            Screenshot(id: "with-bg", appearance: .light, os: .macOS, backgroundHex: "#FF00FF"),
            Screenshot(id: "no-bezel", appearance: .light, os: .iPadOS, addBezel: false),
            Screenshot(id: "watch", appearance: .dark, os: .watchOS).withOSVersion("11.2"),
        ]
        for original in cases {
            let name = original.screenshotName()
            let parsed = Screenshot.fromScreenshotName(name)
            XCTAssertNotNil(parsed, "round-trip for \(name) failed to parse")
            XCTAssertEqual(parsed?.id, original.id)
            XCTAssertEqual(parsed?.os, original.os)
            XCTAssertEqual(parsed?.orientation, original.orientation)
            XCTAssertEqual(parsed?.appearance, original.appearance)
            XCTAssertEqual(parsed?.addBezel, original.addBezel)
            XCTAssertEqual(parsed?.osVersion, original.osVersion)
            XCTAssertEqual(parsed?.background, original.background)
        }
    }
}

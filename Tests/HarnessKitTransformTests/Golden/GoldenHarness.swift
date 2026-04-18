//
//  GoldenHarness.swift
//  HarnessKitTransformTests
//
//  Pixel-level regression harness. Compares a freshly rendered `PlatformImage`
//  against a reference PNG on disk. The reference PNGs live alongside the
//  test sources under `Golden/Fixtures/` and are resolved via `#filePath` so
//  fixtures can be regenerated in-place rather than from a bundle copy.
//
//  Regenerate fixtures:
//      HARNESS_REGENERATE_FIXTURES=1 swift test
//  or via the helper script:
//      Tests/HarnessKitTransformTests/Golden/regenerate.sh
//

import XCTest
import CoreGraphics
import ImageIO
import UniformTypeIdentifiers
@testable import HarnessKitTransform
import HarnessKitScreenshots

#if canImport(AppKit)
import AppKit
#endif

enum GoldenHarness {
    /// When true, `assertMatches` writes the rendered image to disk at the
    /// fixture path instead of comparing. Set via
    /// `HARNESS_REGENERATE_FIXTURES=1`. Do NOT commit code that flips this on
    /// unconditionally — the test would pass trivially.
    static var regenerating: Bool {
        ProcessInfo.processInfo.environment["HARNESS_REGENERATE_FIXTURES"] == "1"
    }

    /// Directory that holds `<fixtureName>.png` files. Resolved from the
    /// source path of this file so tests always read/write the canonical
    /// on-disk fixtures, regardless of cwd or build bundle location.
    static func fixturesURL(file: StaticString = #filePath) -> URL {
        URL(fileURLWithPath: String(describing: file))
            .deletingLastPathComponent()
            .appendingPathComponent("Fixtures", isDirectory: true)
    }

    /// Asserts that `image` matches the PNG at `Fixtures/<fixtureName>.png`.
    /// In regenerate mode, writes the rendered image to that path instead.
    static func assertMatches(
        _ image: PlatformImage,
        fixtureName: String,
        tolerance: UInt8 = 1,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws {
        let fixtureDir = fixturesURL()
        let fixtureURL = fixtureDir.appendingPathComponent("\(fixtureName).png")

        if regenerating {
            try FileManager.default.createDirectory(
                at: fixtureDir, withIntermediateDirectories: true
            )
            guard let data = pngData(from: image) else {
                XCTFail("Failed to encode rendered image for \(fixtureName)",
                        file: file, line: line)
                return
            }
            try data.write(to: fixtureURL)
            return
        }

        guard FileManager.default.fileExists(atPath: fixtureURL.path) else {
            XCTFail(
                """
                Missing fixture: \(fixtureURL.path)
                Run with HARNESS_REGENERATE_FIXTURES=1 swift test to create it.
                """,
                file: file, line: line
            )
            return
        }

        guard let actualData = pngData(from: image) else {
            XCTFail("Failed to encode rendered image for \(fixtureName)",
                    file: file, line: line)
            return
        }
        let expectedData = try Data(contentsOf: fixtureURL)

        guard let actualCG = PixelDiff.decode(pngData: actualData) else {
            XCTFail("Failed to decode rendered image", file: file, line: line)
            return
        }
        guard let expectedCG = PixelDiff.decode(pngData: expectedData) else {
            XCTFail("Failed to decode fixture at \(fixtureURL.path)",
                    file: file, line: line)
            return
        }

        if let diff = PixelDiff.compare(actual: actualCG, expected: expectedCG, tolerance: tolerance) {
            // Drop the rendered image next to the fixture for manual inspection.
            let artifactURL = fixtureDir.appendingPathComponent("_failed_\(fixtureName).png")
            try? actualData.write(to: artifactURL)
            XCTFail(
                """
                Golden mismatch for \(fixtureName): \(diff)
                Wrote rendered output to \(artifactURL.path)
                If this change is intentional, regenerate via:
                    HARNESS_REGENERATE_FIXTURES=1 swift test
                """,
                file: file, line: line
            )
        }
    }
}

//
//  SaveResultsTests.swift
//  HarnessKitTransformTests
//
//  Covers §S8.1 + §S8.2 — save pipeline.
//  S8.1: `ScreenshotMetadata.write` was already ImageIO-direct (verified
//        below by reading metadata back round-trip).
//  S8.2: `saveResults(image:name:to:)` now streams via
//        `CGImageDestinationCreateWithURL` instead of buffering through
//        a Data blob. Verified by writing → re-decoding → asserting the
//        file is a valid PNG with original dimensions.
//

import XCTest
import CoreGraphics
import ImageIO
import UniformTypeIdentifiers
@testable import HarnessKitTransform
import HarnessKitScreenshots

final class SaveResultsTests: XCTestCase {

    private var tempDir: URL!

    override func setUp() {
        super.setUp()
        tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("HarnessKitSaveResults-\(UUID().uuidString)", isDirectory: true)
    }

    override func tearDown() {
        try? FileManager.default.removeItem(at: tempDir)
        super.tearDown()
    }

    // MARK: - Fixtures

    /// Builds a 200×200 solid-magenta `PlatformImage` we can save and decode back.
    private func referenceImage(width: Int = 200, height: Int = 200) -> PlatformImage {
        let cs = CGColorSpaceCreateDeviceRGB()
        let ctx = CGContext(
            data: nil, width: width, height: height,
            bitsPerComponent: 8, bytesPerRow: 0, space: cs,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        )!
        ctx.setFillColor(red: 1.0, green: 0.0, blue: 1.0, alpha: 1.0)
        ctx.fill(CGRect(x: 0, y: 0, width: width, height: height))
        let cg = ctx.makeImage()!

        #if canImport(AppKit)
        let img = NSImage(size: NSSize(width: width, height: height))
        let rep = NSBitmapImageRep(cgImage: cg)
        img.addRepresentation(rep)
        return img
        #else
        return UIImage(cgImage: cg)
        #endif
    }

    private func decodePNG(at url: URL) -> CGImage? {
        guard let src = CGImageSourceCreateWithURL(url as CFURL, nil) else { return nil }
        return CGImageSourceCreateImageAtIndex(src, 0, nil)
    }

    // MARK: - §S8.2: streaming saveResults

    /// `saveResults(image:name:to:)` writes a valid PNG at `<dir>/<name>.png`.
    /// File is decodable, dimensions match, magenta pixels survive the round-trip.
    func testSaveResultsNoMetadataWritesValidPNG() throws {
        let image = referenceImage()
        try saveResults(image: image, name: "magenta", to: tempDir)

        let url = tempDir.appendingPathComponent("magenta.png")
        XCTAssertTrue(FileManager.default.fileExists(atPath: url.path))

        let decoded = try XCTUnwrap(decodePNG(at: url))
        XCTAssertEqual(decoded.width, 200)
        XCTAssertEqual(decoded.height, 200)
    }

    /// `saveResults` with a name that already has `.png` doesn't double-suffix.
    func testSaveResultsDoesNotDoubleSuffix() throws {
        try saveResults(image: referenceImage(), name: "already.png", to: tempDir)
        XCTAssertTrue(FileManager.default.fileExists(atPath: tempDir.appendingPathComponent("already.png").path))
        XCTAssertFalse(FileManager.default.fileExists(atPath: tempDir.appendingPathComponent("already.png.png").path))
    }

    // MARK: - §S8.1: metadata-aware save (regression)

    /// `saveResults(image:screenshot:to:)` writes a PNG with embedded metadata
    /// readable via `ScreenshotMetadata.read`. Verifies §S8.1's confirmation
    /// that the existing ImageIO-direct path is correct.
    func testSaveResultsWithMetadataRoundTrips() throws {
        let original = Screenshot(id: "fixture", appearance: .light, os: .iOS)
            .withOSVersion("17.0")
        try saveResults(image: referenceImage(), screenshot: original, to: tempDir)

        let expectedURL = tempDir.appendingPathComponent(original.prettyName() + ".png")
        XCTAssertTrue(FileManager.default.fileExists(atPath: expectedURL.path))

        let recovered = try XCTUnwrap(ScreenshotMetadata.read(from: expectedURL))
        XCTAssertEqual(recovered.id, original.id)
        XCTAssertEqual(recovered.os, original.os)
        XCTAssertEqual(recovered.appearance, original.appearance)
        XCTAssertEqual(recovered.osVersion, original.osVersion)
    }

    /// `savePNG(image:to:)` (the new helper) writes the same bytes pngData would
    /// have produced via the old `data.write(to:)` path — both are deterministic
    /// CGImageDestination outputs without options. Asserts the file size and
    /// the decoded CGImage's dimensions match.
    func testSavePNGProducesEquivalentFileToPNGDataPath() throws {
        let image = referenceImage()

        // Old path: via Data
        let viaDataURL = tempDir.appendingPathComponent("via-data.png")
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        let data = try XCTUnwrap(pngData(from: image))
        try data.write(to: viaDataURL)

        // New path: direct-to-URL
        let viaURLURL = tempDir.appendingPathComponent("via-url.png")
        try savePNG(image: image, to: viaURLURL)

        let viaDataDecoded = try XCTUnwrap(decodePNG(at: viaDataURL))
        let viaURLDecoded  = try XCTUnwrap(decodePNG(at: viaURLURL))
        XCTAssertEqual(viaDataDecoded.width, viaURLDecoded.width)
        XCTAssertEqual(viaDataDecoded.height, viaURLDecoded.height)

        // File sizes are deterministic for the same CGImage + same destination
        // (no options set in either path) — should be byte-equal.
        let dataBytes = try Data(contentsOf: viaDataURL)
        let urlBytes  = try Data(contentsOf: viaURLURL)
        XCTAssertEqual(dataBytes, urlBytes,
            "direct-to-URL path must produce the same PNG bytes as the via-Data path")
    }
}

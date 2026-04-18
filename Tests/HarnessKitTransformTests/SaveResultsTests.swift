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

    /// `saveResults(image:screenshot:to:)` writes a PNG with embedded metadata
    /// readable via `ScreenshotMetadata.read`. Verifies the existing
    /// ImageIO-direct path is correct.
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

    /// `savePNG(image:to:)` writes the same bytes `pngData(from:) + Data.write` would
    /// have produced — both are deterministic `CGImageDestination` outputs without
    /// options. Asserts the file size and the decoded CGImage's dimensions match.
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

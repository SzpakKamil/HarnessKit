//
//  PipelineTests.swift
//  HarnessKitTransformTests
//

import XCTest
@testable import HarnessKitTransform
import HarnessKitScreenshots

/// Creates a solid-color test NSImage at the given pixel dimensions.
private func makeTestImage(width: Int, height: Int, color: NSColor = .red) -> NSImage {
    NSImage(size: NSSize(width: width, height: height), flipped: false) { rect in
        color.setFill()
        rect.fill()
        return true
    }
}

final class PipelineTests: XCTestCase {

    // MARK: - parseKeyedFilename

    func testParseKeyedFilename_basic() {
        let fields = parseKeyedFilename("device*iPhone16^color*Black.png")
        XCTAssertEqual(fields["device"], "iPhone16")
        XCTAssertEqual(fields["color"], "Black")
    }

    func testParseKeyedFilename_emptyString() {
        let fields = parseKeyedFilename("")
        XCTAssertTrue(fields.isEmpty)
    }

    func testParseKeyedFilename_noDelimiters() {
        let fields = parseKeyedFilename("plainfilename.png")
        XCTAssertTrue(fields.isEmpty)
    }

    func testParseKeyedFilename_multipleFields() {
        let fields = parseKeyedFilename("device*MacbookPro^size*14^models*M2+M3^color*Silver^os*26^wallpaper*Default^appearance*Light.png")
        XCTAssertEqual(fields["device"], "MacbookPro")
        XCTAssertEqual(fields["size"], "14")
        XCTAssertEqual(fields["models"], "M2+M3")
        XCTAssertEqual(fields["color"], "Silver")
        XCTAssertEqual(fields["os"], "26")
        XCTAssertEqual(fields["wallpaper"], "Default")
        XCTAssertEqual(fields["appearance"], "Light")
    }

    // MARK: - ComposeCanvas

    func testComposeCanvas_zeroCanvasSize_returnsEmptyImage() {
        let result = composeCanvas(layers: [], canvasSize: NSSize(width: 0, height: 0))
        XCTAssertEqual(result.size, .zero)
    }

    func testComposeCanvas_singleLayer_centered() {
        let layer = CanvasLayer(image: makeTestImage(width: 100, height: 100), x: 0, y: 0, scale: 1.0)
        let result = composeCanvas(layers: [layer], canvasSize: NSSize(width: 200, height: 200))
        XCTAssertEqual(result.size.width, 200)
        XCTAssertEqual(result.size.height, 200)
    }

    func testComposeCanvas_emptyLayers_returnsCanvas() {
        let result = composeCanvas(layers: [], canvasSize: NSSize(width: 100, height: 100))
        XCTAssertEqual(result.size.width, 100)
        XCTAssertEqual(result.size.height, 100)
    }

    // MARK: - ApplyOrientation

    func testApplyOrientation_portrait_unchanged() {
        let image = makeTestImage(width: 100, height: 200)
        let result = applyOrientation(image: image, orientation: .portrait)
        XCTAssertEqual(result.size.width, 100)
        XCTAssertEqual(result.size.height, 200)
    }

    func testApplyOrientation_landscape_rotated() {
        let image = makeTestImage(width: 100, height: 200)
        let result = applyOrientation(image: image, orientation: .landscape)
        XCTAssertEqual(result.size.width, 200)
        XCTAssertEqual(result.size.height, 100)
    }

    // MARK: - MaskScreenshot

    func testMaskScreenshot_zeroRadius_unchanged() {
        let image = makeTestImage(width: 100, height: 100)
        let result = maskScreenshot(image: image, cornerRadius: 0)
        // Zero radius returns original image
        XCTAssertTrue(result === image)
    }

    func testMaskScreenshot_nonZeroRadius_sameSize() {
        let image = makeTestImage(width: 100, height: 100)
        let result = maskScreenshot(image: image, cornerRadius: 10)
        XCTAssertEqual(result.size.width, 100)
        XCTAssertEqual(result.size.height, 100)
    }

    // MARK: - PlaceBezel zero-size guards

    func testPlaceBezel_zeroSizeImage_returnsOriginal() {
        let image = makeTestImage(width: 0, height: 0)
        let bezel = makeTestImage(width: 100, height: 200)
        let result = placeBezel(image: image, bezel: bezel, verticalOffset: 0)
        XCTAssertTrue(result === image)
    }

    func testPlaceBezel_zeroSizeBezel_returnsOriginal() {
        let image = makeTestImage(width: 100, height: 200)
        let bezel = makeTestImage(width: 0, height: 0)
        let result = placeBezel(image: image, bezel: bezel, verticalOffset: 0)
        XCTAssertTrue(result === image)
    }

    // MARK: - ScaleToBezel

    func testScaleToBezel_factorOne_sameSize() {
        let image = makeTestImage(width: 100, height: 200)
        let result = scaleToBezel(image: image, factor: 1.0)
        XCTAssertEqual(result.size.width, 100)
        XCTAssertEqual(result.size.height, 200)
    }

    // MARK: - TransformError descriptions

    func testTransformError_notInManifest_description() {
        let error = TransformError.notInManifest(paths: ["bezels/phone/device*iPhone11^color*Default.png"])
        XCTAssertTrue(error.localizedDescription.contains("Missing from manifest"))
        XCTAssertTrue(error.localizedDescription.contains("1 file"))
    }

    func testTransformError_bezelFileNotFound_description() {
        let error = TransformError.bezelFileNotFound(id: "iPhone16", color: "Black")
        XCTAssertTrue(error.localizedDescription.contains("iPhone16"))
        XCTAssertTrue(error.localizedDescription.contains("Black"))
    }

    func testTransformError_manifestNotLoaded_description() {
        let error = TransformError.manifestNotLoaded
        XCTAssertTrue(error.localizedDescription.contains("No manifest loaded"))
    }
}

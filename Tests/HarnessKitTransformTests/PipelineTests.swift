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

    // MARK: - Canvas Renderer

    func testRenderCanvas_zeroCanvasSize_returnsEmptyImage() {
        let composition = CanvasComposition(width: 0, height: 0)
        let result = Canvas.render(composition)
        XCTAssertEqual(result.size, .zero)
    }

    func testRenderCanvas_emptyLayers_returnsCanvas() {
        let composition = CanvasComposition(width: 100, height: 100)
        let result = Canvas.render(composition)
        XCTAssertEqual(result.size.width, 100)
        XCTAssertEqual(result.size.height, 100)
    }

    func testRenderCanvas_shapeLayer_rendersAtCorrectSize() {
        let layer = CanvasLayer(
            name: "Test Shape",
            content: .shape(CanvasShapeStyle(path: .rectangle(cornerRadius: 0), fill: .solid(hex: "FF0000", opacity: 1.0))),
            frame: CanvasLayerFrame(x: 0.5, y: 0.5, width: 0.5, height: 0.5)
        )
        let composition = CanvasComposition(width: 200, height: 200, layers: [layer])
        let result = Canvas.render(composition)
        XCTAssertEqual(result.size.width, 200)
        XCTAssertEqual(result.size.height, 200)
    }

    func testRenderCanvas_textLayer_rendersWithoutCrash() {
        let layer = CanvasLayer(
            name: "Test Text",
            content: .text("Hello", CanvasTextStyle()),
            frame: CanvasLayerFrame(x: 0.5, y: 0.5, width: 0.8, height: 0.2)
        )
        let composition = CanvasComposition(width: 200, height: 200, layers: [layer])
        let result = Canvas.render(composition)
        XCTAssertEqual(result.size.width, 200)
    }

    // MARK: - CanvasComposition serialization

    func testCanvasComposition_roundTrip() throws {
        let layer = CanvasLayer(
            name: "iPhone",
            content: .device(CanvasDeviceConfig(platform: "iOS", deviceID: "iPhone17", color: "Black")),
            frame: CanvasLayerFrame(x: 0.3, y: 0.5, width: 0.4, height: 0.9),
            shadows: [.drop(), .contact()],
            effects: [.cornerRadius(radius: 10)]
        )
        let composition = CanvasComposition(
            width: 2089, height: 1440,
            background: .gradient(startHex: "E0E7FF", endHex: "FFFFFF", angle: 180),
            layers: [layer]
        )
        let data = try JSONEncoder().encode(composition)
        let decoded = try JSONDecoder().decode(CanvasComposition.self, from: data)
        XCTAssertEqual(composition, decoded)
    }

    // MARK: - ApplyOrientation

    func testApplyOrientation_portrait_unchanged() {
        let image = makeTestImage(width: 100, height: 200)
        let result = Pipeline.applyOrientation(image, orientation: .portrait)
        XCTAssertEqual(result.size.width, 100)
        XCTAssertEqual(result.size.height, 200)
    }

    func testApplyOrientation_landscape_rotated() {
        let image = makeTestImage(width: 100, height: 200)
        let result = Pipeline.applyOrientation(image, orientation: .landscape)
        XCTAssertEqual(result.size.width, 200)
        XCTAssertEqual(result.size.height, 100)
    }

    // MARK: - MaskScreenshot

    func testMaskScreenshot_zeroRadius_unchanged() {
        let image = makeTestImage(width: 100, height: 100)
        let result = Pipeline.mask(image, cornerRadius: 0)
        // Zero radius returns original image
        XCTAssertTrue(result === image)
    }

    func testMaskScreenshot_nonZeroRadius_sameSize() {
        let image = makeTestImage(width: 100, height: 100)
        let result = Pipeline.mask(image, cornerRadius: 10)
        XCTAssertEqual(result.size.width, 100)
        XCTAssertEqual(result.size.height, 100)
    }

    // MARK: - PlaceBezel zero-size guards

    func testPlaceBezel_zeroSizeImage_returnsOriginal() {
        let image = makeTestImage(width: 0, height: 0)
        let bezel = makeTestImage(width: 100, height: 200)
        let result = Pipeline.placeBezel(image, bezel: bezel, verticalOffset: 0)
        XCTAssertTrue(result === image)
    }

    func testPlaceBezel_zeroSizeBezel_returnsOriginal() {
        let image = makeTestImage(width: 100, height: 200)
        let bezel = makeTestImage(width: 0, height: 0)
        let result = Pipeline.placeBezel(image, bezel: bezel, verticalOffset: 0)
        XCTAssertTrue(result === image)
    }

    // MARK: - ScaleToBezel

    func testScaleToBezel_factorOne_sameSize() {
        let image = makeTestImage(width: 100, height: 200)
        let result = Pipeline.scale(image, by: 1.0)
        XCTAssertEqual(result.size.width, 100)
        XCTAssertEqual(result.size.height, 200)
    }

    // MARK: - §S4.5 adjustResolution sub-pixel slack

    /// Sub-pixel size differences (e.g. 3839.5 × 2160 vs 3840 × 2160)
    /// shouldn't cost a full-canvas redraw. §S4.5 relaxes the short-circuit
    /// from exact equality to within 1.5 px in each dimension.
    func testAdjustResolution_withinOnePixel_returnsInput() {
        let image = makeTestImage(width: 3840, height: 2160)
        // Fake a sub-pixel source by giving NSImage a non-integer size.
        image.size = NSSize(width: 3839.5, height: 2160)
        let result = Pipeline.adjustResolution(image, to: .custom(width: 3840, height: 2160))
        XCTAssertTrue(result === image, "sub-pixel source should short-circuit")
    }

    /// Just past the 1.5 px threshold still goes through the redraw path.
    func testAdjustResolution_pastSlackThreshold_rescales() {
        let image = makeTestImage(width: 3840, height: 2160)
        image.size = NSSize(width: 3838, height: 2160)  // 2 px off → redraws
        let result = Pipeline.adjustResolution(image, to: .custom(width: 3840, height: 2160))
        XCTAssertFalse(result === image)
        XCTAssertEqual(result.size.width, 3840)
        XCTAssertEqual(result.size.height, 2160)
    }

    // MARK: - §S4.4 cropImage fast paths

    /// Pan with no zoom is a no-op: `panX/panY` formulas multiply by
    /// `(imgSize - sourceSize)/2` which collapses to zero when
    /// `sourceSize == imgSize`. §S4.4 extends the short-circuit to skip
    /// the CGImage materialization + full-canvas bitmap entirely.
    func testCropImage_panWithNoZoom_returnsIdentity() {
        let image = makeTestImage(width: 100, height: 200)
        let result = Pipeline.crop(image, to: CropRect(x: 0.5, y: -0.3, width: 1.0, height: 1.0))
        XCTAssertTrue(result === image, "pan-with-no-zoom should be identity, saving the full-canvas redraw")
    }

    /// The original (0,0,1,1) short-circuit must still fire after §S4.4's refactor.
    func testCropImage_identity_returnsInput() {
        let image = makeTestImage(width: 100, height: 200)
        let result = Pipeline.crop(image, to: CropRect(x: 0, y: 0, width: 1.0, height: 1.0))
        XCTAssertTrue(result === image)
    }

    /// Zoom + pan still goes through the rescale path and produces a
    /// viewport-sized output. Ensures §S4.4's fast path doesn't swallow
    /// cases that actually need resampling.
    func testCropImage_zoomPan_rescaleToViewport() {
        let image = makeTestImage(width: 400, height: 300)
        let result = Pipeline.crop(image, to: CropRect(x: 0.2, y: 0, width: 1.5, height: 1.5))
        XCTAssertEqual(result.size.width, 400)
        XCTAssertEqual(result.size.height, 300)
        XCTAssertFalse(result === image, "rescale path should allocate a new image")
    }

    // MARK: - §S4.2 rotation/scale commutativity

    /// The no-bezel L→L optimization in `applyNoBezelPipeline` replaces
    /// `normalizeToPortrait → scaleToBezel → applyOrientation(.landscape)`
    /// with `normalizeOrientation → scaleToBezel`. For that to be
    /// pixel-safe the two sequences must produce bit-identical output on
    /// the pixels §S4.2 is allowed to touch — i.e. before shadows/
    /// background/crop/resolution. Exact-90° rotation is lossless and
    /// commutes with uniform scaling under a symmetric resampling kernel.
    /// This test pins that invariant so the production optimization can't
    /// drift.
    func testNoBezel_L2L_rotationAndScaleCommute_bitForBit() throws {
        let input = makeTestImage(width: 780, height: 360)

        var raw = Pipeline.normalizeToPortrait(input, os: .iOS)
        raw = Pipeline.scale(raw, by: 0.9)
        raw = Pipeline.applyOrientation(raw, orientation: .landscape)

        var optimized = normalizeOrientation(input)
        optimized = Pipeline.scale(optimized, by: 0.9)

        XCTAssertEqual(raw.size, optimized.size)

        guard let rawCG = cgImage(from: raw),
              let optCG = cgImage(from: optimized) else {
            XCTFail("cgImage conversion failed")
            return
        }
        XCTAssertEqual(rawCG.width, optCG.width)
        XCTAssertEqual(rawCG.height, optCG.height)

        let rawPixels = try rgbaBytes(cgImage: rawCG)
        let optPixels = try rgbaBytes(cgImage: optCG)
        XCTAssertEqual(rawPixels, optPixels, "§S4.2 optimization diverges from raw sequence")
    }

    private func rgbaBytes(cgImage: CGImage) throws -> [UInt8] {
        let width = cgImage.width
        let height = cgImage.height
        var bytes = [UInt8](repeating: 0, count: width * height * 4)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo: CGBitmapInfo = [.byteOrder32Big, CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)]
        guard let ctx = CGContext(
            data: &bytes,
            width: width, height: height,
            bitsPerComponent: 8, bytesPerRow: width * 4,
            space: colorSpace,
            bitmapInfo: bitmapInfo.rawValue
        ) else {
            throw NSError(domain: "rgbaBytes", code: 1)
        }
        ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        return bytes
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

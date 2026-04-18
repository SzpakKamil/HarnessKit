//
//  GoldenTests.swift
//  HarnessKitTransformTests
//
//  One XCTestCase per fixture. Keeping them independent means a regression
//  in one scenario doesn't mask others, and `--filter` can target a single
//  fixture (`swift test --filter canvasContactShadows3Groups`).
//

import XCTest
@testable import HarnessKitTransform
import HarnessKitScreenshots

#if canImport(AppKit)
// Golden tests only run on macOS right now — they compare bit-for-bit
// against PNG fixtures rendered by AppKit. iOS-platform equivalents would
// drift at the CG rasterizer level; adding those is a separate task.

final class GoldenTests: XCTestCase {

    func testCanvasSolidBackground() throws {
        let image = FixtureBuilders.canvasSolidBackground()
        try GoldenHarness.assertMatches(image, fixtureName: "canvas-solid-background")
    }

    func testCanvasGradientBackground() throws {
        let image = FixtureBuilders.canvasGradientBackground()
        try GoldenHarness.assertMatches(image, fixtureName: "canvas-gradient-background")
    }

    func testCanvasShapeFillStroke() throws {
        let image = FixtureBuilders.canvasShapeFillStroke()
        try GoldenHarness.assertMatches(image, fixtureName: "canvas-shape-fill-stroke")
    }

    func testCanvasTextLayer() throws {
        let image = FixtureBuilders.canvasTextLayer()
        try GoldenHarness.assertMatches(image, fixtureName: "canvas-text-layer")
    }

    func testCanvasContactShadows3Groups() throws {
        let image = FixtureBuilders.canvasContactShadows3Groups()
        try GoldenHarness.assertMatches(image, fixtureName: "canvas-contact-shadows-3groups")
    }

    func testCanvasEffectBlur() throws {
        let image = FixtureBuilders.canvasEffectBlur()
        try GoldenHarness.assertMatches(image, fixtureName: "canvas-effect-blur")
    }

    func testCanvasEffectProgressiveBlur() throws {
        let image = FixtureBuilders.canvasEffectProgressiveBlur()
        try GoldenHarness.assertMatches(image, fixtureName: "canvas-effect-progressive-blur")
    }

    func testCanvasEffectProgressiveFade() throws {
        let image = FixtureBuilders.canvasEffectProgressiveFade()
        try GoldenHarness.assertMatches(image, fixtureName: "canvas-effect-progressive-fade")
    }

    func testCanvasMultilayerCornerRadius() throws {
        let image = FixtureBuilders.canvasMultilayerCornerRadius()
        try GoldenHarness.assertMatches(image, fixtureName: "canvas-multilayer-corner-radius")
    }

    func testCanvasMultiRotatedLayers() throws {
        let image = FixtureBuilders.canvasMultiRotatedLayers()
        try GoldenHarness.assertMatches(image, fixtureName: "canvas-multi-rotated-layers")
    }

    func testNoBezelPipelinePortrait() throws {
        let image = FixtureBuilders.noBezelPipelinePortrait()
        try GoldenHarness.assertMatches(image, fixtureName: "no-bezel-pipeline-portrait")
    }

    func testNoBezelPipelineLandscape() throws {
        let image = FixtureBuilders.noBezelPipelineLandscape()
        try GoldenHarness.assertMatches(image, fixtureName: "no-bezel-pipeline-landscape")
    }

    func testBezelPipelinePortrait() throws {
        let image = FixtureBuilders.bezelPipelinePortrait()
        try GoldenHarness.assertMatches(image, fixtureName: "bezel-pipeline-portrait")
    }

    func testBezelPipelineLandscape() throws {
        let image = FixtureBuilders.bezelPipelineLandscape()
        try GoldenHarness.assertMatches(image, fixtureName: "bezel-pipeline-landscape")
    }

    func testCropImageZoomPan() throws {
        let image = FixtureBuilders.cropImageZoomPan()
        try GoldenHarness.assertMatches(image, fixtureName: "crop-image-zoom-pan")
    }
}

#endif

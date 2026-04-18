//
//  BezelPipelineStressLandscapeUnopt.swift
//  HarnessKitBenchmarks
//
//  Companion to BezelPipelineStressLandscape. Mirrors the pre-§S4.2
//  applyBezelPipeline behavior: prepareScreenshot rotates L→P, compose
//  with the portrait bezel, then applyOrientation rotates the whole
//  composition P→L. Kept as a regression witness so any future
//  reversion shows up as a RSS/time spike.
//

import Foundation
import CoreGraphics
import HarnessKitScreenshots
import HarnessKitTransform

final class BezelPipelineStressLandscapeUnopt: Scenario, @unchecked Sendable {
    let name = "BezelPipelineStressLandscapeUnopt-iPhone-4K"
    let iterations = 5

    private var input: PlatformImage!
    private var bezel: PlatformImage!

    func prepare() throws {
        input = SyntheticImage.gradient(width: 2796, height: 1290)
        bezel = SyntheticImage.gradient(width: 1290, height: 2796)
    }

    func run() throws -> PlatformImage? {
        let prepared = prepareScreenshot(image: input, os: .iOS)
        let prepSize = prepared.size
        let cornerPx = 0.04 * min(prepSize.width, prepSize.height)
        let masked = maskScreenshot(image: prepared, cornerRadius: cornerPx)
        let scaled = scaleToBezel(image: masked, factor: 0.93)
        let bezeled = placeBezel(
            image: scaled,
            bezel: bezel,
            verticalOffset: 0.02,
            horizontalOffset: 0.01,
            screenshotOnTop: false,
            scaleUpToFill: true,
            nativeScreenSize: nil
        )
        return applyOrientation(image: bezeled, orientation: .landscape)
    }

    func teardown() {
        input = nil
        bezel = nil
    }
}

//
//  NoBezelPipelineStressLandscapeUnopt.swift
//  HarnessKitBenchmarks
//
//  Companion to NoBezelPipelineStressLandscape. Mirrors the pre-§S4.2
//  applyNoBezelPipeline behavior: normalizeToPortrait rotates L→P, scale
//  in portrait, then applyOrientation rotates P→L. Kept as a regression
//  witness so any future reversion shows up as a RSS/time spike.
//

import Foundation
import CoreGraphics
import HarnessKitScreenshots
import HarnessKitTransform

final class NoBezelPipelineStressLandscapeUnopt: Scenario, @unchecked Sendable {
    let name = "NoBezelPipelineStressLandscapeUnopt-iPhone-4K"
    let iterations = 5

    private var input: PlatformImage!

    func prepare() throws {
        input = SyntheticImage.gradient(width: 2796, height: 1290)
    }

    func run() throws -> PlatformImage? {
        var result = Pipeline.normalizeToPortrait(input, os: .iOS)
        result = Pipeline.scale(result, by: 0.92)
        result = Pipeline.applyOrientation(result, orientation: .landscape)
        let compSize = result.size
        let center = CGPoint(x: compSize.width / 2, y: compSize.height / 2)
        result = Pipeline.applyShadows(to: result, shadows: [
                .drop(DropShadow(color: "000000", opacity: 0.4, blur: 0.02, offsetX: 0, offsetY: 0.015)),
                .shape(ShapeShadow(color: "000000", opacity: 0.25, blur: 0.06,
                                    x: 0, y: -1.02, width: 1.2, height: 0.05, cornerRadius: 1.0)),
            ],
            compositionSize: compSize,
            compositionCenter: center
        )
        result = Pipeline.addBackground(to: result, background: .gradient(startHex: "0F1115", endHex: "202428", angle: 180))
        result = Pipeline.crop(result, to: CropRect(x: 0, y: 0, width: 1, height: 1))
        result = Pipeline.adjustResolution(result, to: .custom(width: 3840, height: 2160))
        return result
    }

    func teardown() {
        input = nil
    }
}

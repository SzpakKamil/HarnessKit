//
//  NoBezelPipelineStressLandscape.swift
//  HarnessKitBenchmarks
//
//  Witness for §S4.2 no-bezel L→L optimization. Mirrors the optimized
//  branch of `applyNoBezelPipeline` on iOS/iPadOS: the landscape input
//  skips both rotations (prepareScreenshot's L→P and applyOrientation's
//  P→L cancel). On macOS, `normalizeOrientation` is identity, so mirror
//  that by using the raw input directly.
//

import Foundation
import CoreGraphics
import HarnessKitScreenshots
import HarnessKitTransform

final class NoBezelPipelineStressLandscape: Scenario, @unchecked Sendable {
    let name = "NoBezelPipelineStressLandscape-iPhone-4K"
    let iterations = 5

    private var input: PlatformImage!

    func prepare() throws {
        input = SyntheticImage.gradient(width: 2796, height: 1290)
    }

    func run() throws -> PlatformImage? {
        var result = input!
        result = scaleToBezel(image: result, factor: 0.92)
        let compSize = result.size
        let center = CGPoint(x: compSize.width / 2, y: compSize.height / 2)
        result = applyShadows(
            image: result,
            shadows: [
                .drop(DropShadow(color: "000000", opacity: 0.4, blur: 0.02, offsetX: 0, offsetY: 0.015)),
                .shape(ShapeShadow(color: "000000", opacity: 0.25, blur: 0.06,
                                    x: 0, y: -1.02, width: 1.2, height: 0.05, cornerRadius: 1.0)),
            ],
            compositionSize: compSize,
            compositionCenter: center
        )
        result = addBackground(image: result, background: .gradient(startHex: "0F1115", endHex: "202428", angle: 180))
        result = cropImage(image: result, crop: CropRect(x: 0, y: 0, width: 1, height: 1))
        result = adjustResolution(image: result, resolution: .custom(width: 3840, height: 2160))
        return result
    }

    func teardown() {
        input = nil
    }
}

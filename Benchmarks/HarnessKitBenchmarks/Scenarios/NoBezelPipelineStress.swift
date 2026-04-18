//
//  NoBezelPipelineStress.swift
//  HarnessKitBenchmarks
//
//  Runs the publicly-exposed steps of the no-bezel pipeline end-to-end
//  without needing network-backed bezels. Mirrors what
//  `applyNoBezelPipeline` does internally: prepare → scale → orient →
//  shadows → background → crop → resolution.
//

import Foundation
import CoreGraphics
import HarnessKitScreenshots
import HarnessKitTransform

final class NoBezelPipelineStress: Scenario, @unchecked Sendable {
    let name = "NoBezelPipelineStress-iPhone-4K"
    let iterations = 5

    private var input: PlatformImage!

    func prepare() throws {
        // iPhone 14 Pro Max portrait pixel size.
        input = SyntheticImage.gradient(width: 1290, height: 2796)
    }

    func run() throws -> PlatformImage? {
        var result = prepareScreenshot(image: input, os: .iOS)
        result = scaleToBezel(image: result, factor: 0.92)
        result = applyOrientation(image: result, orientation: .portrait)
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

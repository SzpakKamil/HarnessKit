//
//  BezelPipelineStressLandscape.swift
//  HarnessKitBenchmarks
//
//  Witness for §S4.2 bezel L→L optimization. Calls `applyBezelPipeline`
//  directly with a landscape-shaped input and `.landscape` target
//  orientation — the exact case §S4.2 collapses the double-rotation
//  from two full-composition bitmaps to one bezel bitmap.
//

import Foundation
import CoreGraphics
import HarnessKitScreenshots
import HarnessKitTransform

final class BezelPipelineStressLandscape: Scenario, @unchecked Sendable {
    let name = "BezelPipelineStressLandscape-iPhone-4K"
    let iterations = 5

    private var input: PlatformImage!
    private var bezel: PlatformImage!

    func prepare() throws {
        input = SyntheticImage.gradient(width: 2796, height: 1290)
        // Synthetic portrait bezel at iPhone 14 Pro Max native resolution.
        bezel = SyntheticImage.gradient(width: 1290, height: 2796)
    }

    func run() throws -> PlatformImage? {
        let params = BezelPipelineParams(
            os: .iOS,
            bezelImage: bezel,
            scale: 0.93,
            verticalOffset: 0.02,
            horizontalOffset: 0.01,
            cornerRadius: 0.04,
            screenshotOnTop: false,
            scaleUpToFill: true,
            orientation: .landscape,
            nativeScreenSize: nil
        )
        return Pipeline.applyBezel(to: input, params: params)
    }

    func teardown() {
        input = nil
        bezel = nil
    }
}

//
//  CropImageStress.swift
//  HarnessKitBenchmarks
//
//  Witness for §S4.4 cropImage fast path. Alternates between pan-only
//  (short-circuit fires — zero alloc) and zoom+pan (rescale path runs)
//  so the peak RSS spans both branches in one scenario.
//

import Foundation
import CoreGraphics
import HarnessKitScreenshots
import HarnessKitTransform

final class CropImageStress: Scenario, @unchecked Sendable {
    let name = "CropImageStress-4K"
    let iterations = 5

    private var input: PlatformImage!

    func prepare() throws {
        input = SyntheticImage.gradient(width: 3840, height: 2160)
    }

    func run() throws -> PlatformImage? {
        // Pan-only: §S4.4 short-circuits (identity, no bitmap).
        let panned = cropImage(image: input, crop: CropRect(x: 0.3, y: -0.2, width: 1.0, height: 1.0))
        // Zoom + pan: goes through the rescale path.
        return cropImage(image: panned, crop: CropRect(x: 0.1, y: 0.1, width: 1.5, height: 1.5))
    }

    func teardown() {
        input = nil
    }
}

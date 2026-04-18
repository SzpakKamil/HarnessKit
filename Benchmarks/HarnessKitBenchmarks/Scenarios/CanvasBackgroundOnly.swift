//
//  CanvasBackgroundOnly.swift
//  HarnessKitBenchmarks
//
//  Floor scenario: renderCanvas with only a solid background and no layers.
//  Establishes the unavoidable cost of allocating the canvas bitmap and the
//  background fill; every other scenario pays at least this much.
//

import Foundation
import HarnessKitScreenshots
import HarnessKitTransform

final class CanvasBackgroundOnly: Scenario, @unchecked Sendable {
    let name = "CanvasBackgroundOnly-4K"
    let iterations = 5

    func run() throws -> PlatformImage? {
        let comp = CanvasComposition(
            width: 3840, height: 2160,
            background: .solid(hex: "202428"),
            layers: []
        )
        return renderCanvas(comp)
    }
}

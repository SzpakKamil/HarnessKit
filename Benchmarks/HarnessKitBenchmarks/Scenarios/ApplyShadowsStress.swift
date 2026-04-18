//
//  ApplyShadowsStress.swift
//  HarnessKitBenchmarks
//
//  Direct exercise of the non-canvas `applyShadows` path — which is used by
//  the no-bezel pipeline and bezel-on-canvas workflows. Same 3-blur-group
//  layout as `CanvasShadowStress`; lets us distinguish §S3.2's canvas fix
//  from the ApplyShadow.swift rewrite in the same §S3.2.
//

import Foundation
import CoreGraphics
import HarnessKitScreenshots
import HarnessKitTransform

final class ApplyShadowsStress: Scenario, @unchecked Sendable {
    let name = "ApplyShadowsStress-4K-3groups"
    let iterations = 3

    private var canvas: PlatformImage!

    func prepare() throws {
        canvas = SyntheticImage.gradient(width: 3840, height: 2160)
    }

    func run() throws -> PlatformImage? {
        let shadows: [ScreenshotShadow] = [
            .shape(ShapeShadow(color: "000000", opacity: 0.4, blur: 0.03,
                                x: 0, y: -1.0, width: 1.1, height: 0.03, cornerRadius: 1.0)),
            .shape(ShapeShadow(color: "000000", opacity: 0.25, blur: 0.07,
                                x: 0, y: -1.03, width: 1.3, height: 0.05, cornerRadius: 1.0)),
            .shape(ShapeShadow(color: "000000", opacity: 0.15, blur: 0.12,
                                x: 0, y: -1.08, width: 1.6, height: 0.08, cornerRadius: 1.0)),
            .drop(DropShadow(color: "000000", opacity: 0.35, blur: 0.02, offsetX: 0, offsetY: 0.01)),
        ]
        let compSize = CGSize(width: 3840, height: 2160)
        let center = CGPoint(x: compSize.width / 2, y: compSize.height / 2)
        return Pipeline.applyShadows(to: canvas, shadows: shadows,
                            compositionSize: compSize, compositionCenter: center)
    }

    func teardown() {
        canvas = nil
    }
}

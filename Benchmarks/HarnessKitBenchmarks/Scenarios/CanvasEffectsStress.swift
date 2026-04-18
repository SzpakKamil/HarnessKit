//
//  CanvasEffectsStress.swift
//  HarnessKitBenchmarks
//
//  Layer with four chained effects — each one currently allocates a
//  full-canvas intermediate bitmap. The §S3.1 fused-CIFilter rewrite should
//  collapse the chain into a single render.
//

import Foundation
import HarnessKitScreenshots
import HarnessKitTransform

final class CanvasEffectsStress: Scenario, @unchecked Sendable {
    let name = "CanvasEffectsStress-4K-4effects"
    let iterations = 3

    private var deviceImage: PlatformImage!
    private var deviceLayerID: UUID!

    func prepare() throws {
        deviceImage = SyntheticImage.gradient(width: 1500, height: 2000)
        deviceLayerID = UUID()
    }

    func run() throws -> PlatformImage? {
        let effects: [CanvasLayerEffect] = [
            .blur(radius: 12),
            .colorOverlay(hex: "FFD166", opacity: 0.12),
            .progressiveBlur(radius: 24, direction: .topToBottom, startPoint: 0.0, endPoint: 1.0),
            .progressiveFade(direction: .bottomToTop, startPoint: 0.0, endPoint: 1.0),
        ]
        let layer = CanvasLayer(
            id: deviceLayerID,
            name: "Device",
            content: .device(CanvasDeviceConfig(platform: "", deviceID: "")),
            frame: CanvasLayerFrame(x: 0.5, y: 0.5, width: 0.35, height: 0.75),
            effects: effects
        )
        let comp = CanvasComposition(
            width: 3840, height: 2160,
            background: .solid(hex: "0F1115"),
            layers: [layer]
        )
        return Canvas.render(comp, deviceImages: [deviceLayerID: deviceImage])
    }

    func teardown() {
        deviceImage = nil
        deviceLayerID = nil
    }
}

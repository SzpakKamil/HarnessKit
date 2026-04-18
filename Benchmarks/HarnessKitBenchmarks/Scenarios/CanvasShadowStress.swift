//
//  CanvasShadowStress.swift
//  HarnessKitBenchmarks
//
//  Exercises `renderContactShadows` with three distinct blur radii so the
//  current implementation allocates three canvas-sized bitmaps + three CI
//  blur passes per layer. Biggest memory hotspot in the pre-optimization
//  pipeline; this scenario is the main witness for §S3.2.
//

import Foundation
import HarnessKitScreenshots
import HarnessKitTransform

final class CanvasShadowStress: Scenario, @unchecked Sendable {
    let name = "CanvasShadowStress-4K-3groups"
    let iterations = 3

    private var deviceImage: PlatformImage!
    private var deviceLayerID: UUID!

    func prepare() throws {
        deviceImage = SyntheticImage.gradient(width: 1500, height: 2000)
        deviceLayerID = UUID()
    }

    func run() throws -> PlatformImage? {
        let shadows: [CanvasLayerShadow] = [
            CanvasLayerShadow(type: .contact, color: "000000", opacity: 0.40, blur: 0.03,
                              contactWidth: 1.1, contactHeight: 0.03,
                              contactY: -1.02, contactCornerRadius: 1.0),
            CanvasLayerShadow(type: .contact, color: "000000", opacity: 0.25, blur: 0.07,
                              contactWidth: 1.3, contactHeight: 0.05,
                              contactY: -1.05, contactCornerRadius: 1.0),
            CanvasLayerShadow(type: .contact, color: "000000", opacity: 0.15, blur: 0.12,
                              contactWidth: 1.6, contactHeight: 0.08,
                              contactY: -1.10, contactCornerRadius: 1.0),
            CanvasLayerShadow(type: .drop, color: "000000", opacity: 0.35, blur: 0.02,
                              offsetX: 0, offsetY: 0.01),
        ]
        let layer = CanvasLayer(
            id: deviceLayerID,
            name: "Device",
            content: .device(CanvasDeviceConfig(platform: "", deviceID: "")),
            frame: CanvasLayerFrame(x: 0.5, y: 0.5, width: 0.35, height: 0.75),
            shadows: shadows
        )
        let comp = CanvasComposition(
            width: 3840, height: 2160,
            background: .gradient(startHex: "1A1E24", endHex: "3A3F4A", angle: 180),
            layers: [layer]
        )
        return renderCanvas(comp, deviceImages: [deviceLayerID: deviceImage])
    }

    func teardown() {
        deviceImage = nil
        deviceLayerID = nil
    }
}

//
//  CanvasLayerChain.swift
//  HarnessKitBenchmarks
//
//  Multi-layer composition — exercises the per-layer autoreleasepool drain
//  and the corner-radius / background-color branches. Useful for §S3.5
//  ("inline corner-radius") measurement.
//

import Foundation
import HarnessKitScreenshots
import HarnessKitTransform

final class CanvasLayerChain: Scenario, @unchecked Sendable {
    let name = "CanvasLayerChain-4K-6layers"
    let iterations = 3

    private var deviceImage: PlatformImage!
    private var deviceLayerID: UUID!

    func prepare() throws {
        deviceImage = SyntheticImage.gradient(width: 1500, height: 2000)
        deviceLayerID = UUID()
    }

    func run() throws -> PlatformImage? {
        let device = CanvasLayer(
            id: deviceLayerID,
            name: "Device",
            content: .device(CanvasDeviceConfig(platform: "", deviceID: "")),
            frame: CanvasLayerFrame(x: 0.5, y: 0.5, width: 0.3, height: 0.65),
            cornerRadius: 64
        )
        let accent = CanvasLayer(
            id: UUID(),
            name: "Accent",
            content: .shape(CanvasShapeStyle(
                path: .rectangle(cornerRadius: 32),
                fill: .solid(hex: "FF5F6D", opacity: 0.9),
                strokeColor: nil, strokeWidth: 0, strokeOpacity: 0
            )),
            frame: CanvasLayerFrame(x: 0.25, y: 0.75, width: 0.15, height: 0.08),
            cornerRadius: 32
        )
        let subaccent = CanvasLayer(
            id: UUID(),
            name: "Stroke",
            content: .shape(CanvasShapeStyle(
                path: .ellipse,
                fill: nil,
                strokeColor: "FFFFFF",
                strokeWidth: 6,
                strokeOpacity: 0.8
            )),
            frame: CanvasLayerFrame(x: 0.8, y: 0.3, width: 0.12, height: 0.12)
        )
        let headline = CanvasLayer(
            id: UUID(),
            name: "Headline",
            content: .text("Write once. Render anywhere.", CanvasTextStyle(
                fontFamily: "Helvetica Neue",
                fontSize: 120,
                fontWeight: 700,
                isItalic: false,
                color: "FFFFFF",
                alignment: .left,
                verticalAlignment: .top,
                lineSpacing: 1.1,
                letterSpacing: 0,
                shadow: nil
            )),
            frame: CanvasLayerFrame(x: 0.5, y: 0.15, width: 0.7, height: 0.1)
        )
        let panel = CanvasLayer(
            id: UUID(),
            name: "Panel",
            content: .shape(CanvasShapeStyle(
                path: .rectangle(cornerRadius: 0),
                fill: .linearGradient(startHex: "0F1115", endHex: "202428", angle: 45, opacity: 1.0),
                strokeColor: nil, strokeWidth: 0, strokeOpacity: 0
            )),
            frame: CanvasLayerFrame(x: 0.5, y: 0.88, width: 0.85, height: 0.1),
            cornerRadius: 48,
            backgroundColor: "1A1E24"
        )
        let comp = CanvasComposition(
            width: 3840, height: 2160,
            background: .gradient(startHex: "0F1115", endHex: "202428", angle: 180),
            layers: [panel, accent, subaccent, device, headline]
        )
        return renderCanvas(comp, deviceImages: [deviceLayerID: deviceImage])
    }

    func teardown() {
        deviceImage = nil
        deviceLayerID = nil
    }
}

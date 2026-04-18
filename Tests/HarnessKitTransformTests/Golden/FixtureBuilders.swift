//
//  FixtureBuilders.swift
//  HarnessKitTransformTests
//
//  Deterministic renderers for each golden fixture. Each function returns the
//  fully rendered `PlatformImage`; the caller passes it into
//  `GoldenHarness.assertMatches`. Builders MUST NOT read environment state —
//  every input is hardcoded so the output is repeatable on any machine.
//

import Foundation
import CoreGraphics
import HarnessKitScreenshots
@testable import HarnessKitTransform

#if canImport(AppKit)
import AppKit
#endif

enum FixtureBuilders {

    // MARK: - Synthetic inputs

    /// Deterministic gradient bitmap at the requested pixel size. All
    /// fixtures that need a raw "screenshot" or "device image" use this so
    /// results don't depend on any bundled asset.
    static func syntheticImage(width: Int, height: Int) -> PlatformImage {
        #if canImport(AppKit)
        return NSImage(size: NSSize(width: width, height: height), flipped: false) { rect in
            guard let ctx = NSGraphicsContext.current?.cgContext else { return false }
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let gradient = CGGradient(
                colorsSpace: colorSpace,
                colors: [
                    CGColor(red: 0.20, green: 0.45, blue: 0.95, alpha: 1.0),
                    CGColor(red: 0.95, green: 0.35, blue: 0.60, alpha: 1.0)
                ] as CFArray,
                locations: [0, 1]
            )!
            ctx.drawLinearGradient(
                gradient,
                start: CGPoint(x: 0, y: 0),
                end: CGPoint(x: rect.width, y: rect.height),
                options: []
            )
            return true
        }
        #else
        // iOS fallback path is currently not used — Golden tests only run on macOS
        // because the package exposes NSImage-backed rendering here.
        fatalError("Synthetic image builder is macOS-only")
        #endif
    }

    // MARK: - Canvas fixtures

    static func canvasSolidBackground() -> PlatformImage {
        let comp = CanvasComposition(
            width: 320, height: 240,
            background: .solid(hex: "2E3440"),
            layers: []
        )
        return Canvas.render(comp)
    }

    static func canvasGradientBackground() -> PlatformImage {
        let comp = CanvasComposition(
            width: 320, height: 240,
            background: .gradient(startHex: "1E2636", endHex: "3A5080", angle: 135),
            layers: []
        )
        return Canvas.render(comp)
    }

    static func canvasShapeFillStroke() -> PlatformImage {
        let shape = CanvasLayer(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
            name: "Rect",
            content: .shape(CanvasShapeStyle(
                path: .rectangle(cornerRadius: 24),
                fill: .solid(hex: "EF476F", opacity: 1.0),
                strokeColor: "FFFFFF",
                strokeWidth: 6,
                strokeOpacity: 1.0
            )),
            frame: CanvasLayerFrame(x: 0.5, y: 0.5, width: 0.6, height: 0.5)
        )
        let comp = CanvasComposition(
            width: 320, height: 240,
            background: .solid(hex: "1A1E24"),
            layers: [shape]
        )
        return Canvas.render(comp)
    }

    static func canvasTextLayer() -> PlatformImage {
        let text = CanvasLayer(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000002")!,
            name: "Headline",
            content: .text("HarnessKit", CanvasTextStyle(
                fontFamily: "Helvetica Neue",
                fontSize: 42,
                fontWeight: 700,
                isItalic: false,
                color: "FFFFFF",
                alignment: .center,
                verticalAlignment: .center,
                lineSpacing: 1.0,
                letterSpacing: 0,
                shadow: nil
            )),
            frame: CanvasLayerFrame(x: 0.5, y: 0.5, width: 0.9, height: 0.3)
        )
        let comp = CanvasComposition(
            width: 320, height: 240,
            background: .solid(hex: "202428"),
            layers: [text]
        )
        return Canvas.render(comp)
    }

    static func canvasContactShadows3Groups() -> PlatformImage {
        let device = CanvasLayer(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000003")!,
            name: "Device",
            content: .shape(CanvasShapeStyle(
                path: .rectangle(cornerRadius: 16),
                fill: .solid(hex: "FFFFFF", opacity: 1.0),
                strokeColor: nil, strokeWidth: 0, strokeOpacity: 0
            )),
            frame: CanvasLayerFrame(x: 0.5, y: 0.45, width: 0.35, height: 0.5),
            shadows: [
                CanvasLayerShadow(type: .contact, color: "000000", opacity: 0.40,
                                   blur: 0.05,
                                   contactWidth: 1.1, contactHeight: 0.05,
                                   contactY: -1.02, contactCornerRadius: 1.0),
                CanvasLayerShadow(type: .contact, color: "000000", opacity: 0.25,
                                   blur: 0.12,
                                   contactWidth: 1.3, contactHeight: 0.08,
                                   contactY: -1.06, contactCornerRadius: 1.0),
                CanvasLayerShadow(type: .contact, color: "000000", opacity: 0.15,
                                   blur: 0.22,
                                   contactWidth: 1.6, contactHeight: 0.12,
                                   contactY: -1.10, contactCornerRadius: 1.0),
            ]
        )
        let comp = CanvasComposition(
            width: 320, height: 240,
            background: .gradient(startHex: "0F1115", endHex: "2A2F37", angle: 180),
            layers: [device]
        )
        return Canvas.render(comp)
    }

    static func canvasEffectBlur() -> PlatformImage {
        let id = UUID(uuidString: "00000000-0000-0000-0000-000000000004")!
        let shape = CanvasLayer(
            id: id,
            name: "Target",
            content: .shape(CanvasShapeStyle(
                path: .rectangle(cornerRadius: 8),
                fill: .linearGradient(startHex: "FFD166", endHex: "EF476F", angle: 90, opacity: 1.0),
                strokeColor: nil, strokeWidth: 0, strokeOpacity: 0
            )),
            frame: CanvasLayerFrame(x: 0.5, y: 0.5, width: 0.5, height: 0.5),
            effects: [.blur(radius: 8)]
        )
        let comp = CanvasComposition(
            width: 320, height: 240,
            background: .solid(hex: "10151C"),
            layers: [shape]
        )
        return Canvas.render(comp)
    }

    static func canvasEffectProgressiveBlur() -> PlatformImage {
        let id = UUID(uuidString: "00000000-0000-0000-0000-000000000005")!
        let shape = CanvasLayer(
            id: id,
            name: "Target",
            content: .shape(CanvasShapeStyle(
                path: .rectangle(cornerRadius: 8),
                fill: .linearGradient(startHex: "06D6A0", endHex: "118AB2", angle: 45, opacity: 1.0),
                strokeColor: nil, strokeWidth: 0, strokeOpacity: 0
            )),
            frame: CanvasLayerFrame(x: 0.5, y: 0.5, width: 0.6, height: 0.6),
            effects: [.progressiveBlur(radius: 14, direction: .topToBottom, startPoint: 0, endPoint: 1)]
        )
        let comp = CanvasComposition(
            width: 320, height: 240,
            background: .solid(hex: "10151C"),
            layers: [shape]
        )
        return Canvas.render(comp)
    }

    static func canvasEffectProgressiveFade() -> PlatformImage {
        let id = UUID(uuidString: "00000000-0000-0000-0000-000000000006")!
        let shape = CanvasLayer(
            id: id,
            name: "Target",
            content: .shape(CanvasShapeStyle(
                path: .rectangle(cornerRadius: 8),
                fill: .linearGradient(startHex: "FFD166", endHex: "118AB2", angle: 0, opacity: 1.0),
                strokeColor: nil, strokeWidth: 0, strokeOpacity: 0
            )),
            frame: CanvasLayerFrame(x: 0.5, y: 0.5, width: 0.7, height: 0.7),
            effects: [.progressiveFade(direction: .bottomToTop, startPoint: 0, endPoint: 1)]
        )
        let comp = CanvasComposition(
            width: 320, height: 240,
            background: .solid(hex: "1A1E24"),
            layers: [shape]
        )
        return Canvas.render(comp)
    }

    static func canvasMultilayerCornerRadius() -> PlatformImage {
        let bg = CanvasLayer(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000010")!,
            name: "Card",
            content: .shape(CanvasShapeStyle(
                path: .rectangle(cornerRadius: 0),
                fill: .solid(hex: "26303C", opacity: 1.0),
                strokeColor: nil, strokeWidth: 0, strokeOpacity: 0
            )),
            frame: CanvasLayerFrame(x: 0.5, y: 0.5, width: 0.75, height: 0.75),
            cornerRadius: 24
        )
        let accent = CanvasLayer(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000011")!,
            name: "Dot",
            content: .shape(CanvasShapeStyle(
                path: .ellipse,
                fill: .solid(hex: "EF476F", opacity: 1.0),
                strokeColor: nil, strokeWidth: 0, strokeOpacity: 0
            )),
            frame: CanvasLayerFrame(x: 0.35, y: 0.35, width: 0.18, height: 0.18)
        )
        let text = CanvasLayer(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000012")!,
            name: "Label",
            content: .text("Golden", CanvasTextStyle(
                fontFamily: "Helvetica Neue",
                fontSize: 28,
                fontWeight: 600,
                isItalic: false,
                color: "FFFFFF",
                alignment: .center,
                verticalAlignment: .center,
                lineSpacing: 1.0,
                letterSpacing: 0,
                shadow: nil
            )),
            frame: CanvasLayerFrame(x: 0.65, y: 0.6, width: 0.3, height: 0.15)
        )
        let comp = CanvasComposition(
            width: 320, height: 240,
            background: .gradient(startHex: "0F1115", endHex: "1D2330", angle: 180),
            layers: [bg, accent, text]
        )
        return Canvas.render(comp)
    }

    // MARK: - Rotated layers fixture

    /// Five layers with different `frame.rotation` values at different
    /// off-center positions, including one rotation combined with a
    /// continuous corner-radius clip (§S3.5) and one combined with a
    /// shape's built-in corner radius. Guards against rotation-math
    /// regressions — wrong center, wrong sign, lost rotation, or
    /// misordered translate/rotate/translate — any of which would
    /// put pixels in the wrong place and fail the bit-for-bit diff.
    static func canvasMultiRotatedLayers() -> PlatformImage {
        // Reference layer: 0° axis-aligned square at center. Any
        // regression that silently drops the rotation would make every
        // other layer look like this one, and the diff flags it.
        let reference = CanvasLayer(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000020")!,
            name: "Reference",
            content: .shape(CanvasShapeStyle(
                path: .rectangle(cornerRadius: 0),
                fill: .solid(hex: "3E4D66", opacity: 1.0),
                strokeColor: nil, strokeWidth: 0, strokeOpacity: 0
            )),
            frame: CanvasLayerFrame(x: 0.5, y: 0.5, width: 0.40, height: 0.40, rotation: 0)
        )
        // 45° diamond at center — corners stick out along the axes.
        let diamond = CanvasLayer(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000021")!,
            name: "Diamond",
            content: .shape(CanvasShapeStyle(
                path: .rectangle(cornerRadius: 0),
                fill: .solid(hex: "EF476F", opacity: 0.85),
                strokeColor: nil, strokeWidth: 0, strokeOpacity: 0
            )),
            frame: CanvasLayerFrame(x: 0.5, y: 0.5, width: 0.32, height: 0.32, rotation: 45)
        )
        // 15° ellipse in the top-left quadrant with a continuous
        // corner-radius clip applied. Tests rotation × inlined clip
        // interaction from §S3.5.
        let ellipseClipped = CanvasLayer(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000022")!,
            name: "EllipseClipped",
            content: .shape(CanvasShapeStyle(
                path: .ellipse,
                fill: .solid(hex: "06D6A0", opacity: 1.0),
                strokeColor: nil, strokeWidth: 0, strokeOpacity: 0
            )),
            frame: CanvasLayerFrame(x: 0.25, y: 0.25, width: 0.20, height: 0.20, rotation: 15),
            cornerRadius: 12
        )
        // -30° rounded-rect in the bottom-right. Negative rotation +
        // shape's built-in corner radius.
        let roundedRect = CanvasLayer(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000023")!,
            name: "RoundedRect",
            content: .shape(CanvasShapeStyle(
                path: .rectangle(cornerRadius: 18),
                fill: .solid(hex: "FFD166", opacity: 1.0),
                strokeColor: nil, strokeWidth: 0, strokeOpacity: 0
            )),
            frame: CanvasLayerFrame(x: 0.75, y: 0.75, width: 0.22, height: 0.22, rotation: -30)
        )
        // Non-square rectangle rotated exactly 90°. A horizontal bar
        // becomes a vertical bar at the same center. Fastest visual
        // check that the rotate-around-frame-center math is right: if
        // we rotate around the canvas origin instead, this pixel lands
        // in a completely different quadrant.
        let ninetyBar = CanvasLayer(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000024")!,
            name: "NinetyBar",
            content: .shape(CanvasShapeStyle(
                path: .rectangle(cornerRadius: 4),
                fill: .solid(hex: "FFFFFF", opacity: 1.0),
                strokeColor: nil, strokeWidth: 0, strokeOpacity: 0
            )),
            frame: CanvasLayerFrame(x: 0.5, y: 0.12, width: 0.28, height: 0.06, rotation: 90)
        )
        let comp = CanvasComposition(
            width: 400, height: 400,
            background: .solid(hex: "101826"),
            layers: [reference, diamond, ellipseClipped, roundedRect, ninetyBar]
        )
        return Canvas.render(comp)
    }

    /// Deterministic "picture-frame" bezel: opaque dark border around a
    /// transparent interior. Stands in for a real device bezel in Goldens
    /// where bundled bezel assets don't exist yet.
    static func syntheticBezel(width: Int, height: Int) -> PlatformImage {
        #if canImport(AppKit)
        return NSImage(size: NSSize(width: width, height: height), flipped: false) { rect in
            guard let ctx = NSGraphicsContext.current?.cgContext else { return false }
            ctx.setFillColor(CGColor(red: 0.12, green: 0.12, blue: 0.14, alpha: 1.0))
            ctx.fill(rect)
            let inset = min(rect.width, rect.height) * 0.08
            ctx.clear(rect.insetBy(dx: inset, dy: inset))
            return true
        }
        #else
        fatalError("Synthetic bezel builder is macOS-only")
        #endif
    }

    // MARK: - No-bezel pipeline fixture

    /// Mirrors the publicly-visible steps of `applyNoBezelPipeline` on a
    /// synthetic portrait screenshot. Exercises PrepareScreenshot +
    /// ScaleToBezel + ApplyShadows + AddBackground + CropImage +
    /// AdjustResolution together — the full non-canvas path.
    static func noBezelPipelinePortrait() -> PlatformImage {
        let input = syntheticImage(width: 360, height: 780)
        var result = Pipeline.normalizeToPortrait(input, os: .iOS)
        result = Pipeline.scale(result, by: 0.9)
        result = Pipeline.applyOrientation(result, orientation: .portrait)
        let compSize = result.size
        let center = CGPoint(x: compSize.width / 2, y: compSize.height / 2)
        result = Pipeline.applyShadows(to: result, shadows: [
                .drop(DropShadow(color: "000000", opacity: 0.4,
                                  blur: 0.02, offsetX: 0, offsetY: 0.015)),
                .shape(ShapeShadow(color: "000000", opacity: 0.25,
                                    blur: 0.06, x: 0, y: -1.02,
                                    width: 1.2, height: 0.05, cornerRadius: 1.0)),
            ],
            compositionSize: compSize,
            compositionCenter: center
        )
        result = Pipeline.addBackground(to: result, background: .gradient(startHex: "0F1115",
                                                      endHex: "2A2F37",
                                                      angle: 180))
        result = Pipeline.crop(result, to: CropRect(x: 0, y: 0, width: 1, height: 1))
        result = Pipeline.adjustResolution(result, to: .custom(width: 640, height: 480))
        return result
    }

    /// Landscape-in + landscape-out variant of the no-bezel pipeline. The
    /// synthetic input is wider-than-tall so `normalizeToPortrait` rotates
    /// it to portrait on iOS, then `applyOrientation(.landscape)` rotates
    /// the pipeline output back to landscape. This is the exact double-
    /// rotation path §S4.2 optimizes — the Golden pins the current visual
    /// so the optimized code must match bit-for-bit.
    static func noBezelPipelineLandscape() -> PlatformImage {
        let input = syntheticImage(width: 780, height: 360)
        var result = Pipeline.normalizeToPortrait(input, os: .iOS)
        result = Pipeline.scale(result, by: 0.9)
        result = Pipeline.applyOrientation(result, orientation: .landscape)
        let compSize = result.size
        let center = CGPoint(x: compSize.width / 2, y: compSize.height / 2)
        result = Pipeline.applyShadows(to: result, shadows: [
                .drop(DropShadow(color: "000000", opacity: 0.4,
                                  blur: 0.02, offsetX: 0, offsetY: 0.015)),
                .shape(ShapeShadow(color: "000000", opacity: 0.25,
                                    blur: 0.06, x: 0, y: -1.02,
                                    width: 1.2, height: 0.05, cornerRadius: 1.0)),
            ],
            compositionSize: compSize,
            compositionCenter: center
        )
        result = Pipeline.addBackground(to: result, background: .gradient(startHex: "0F1115",
                                                      endHex: "2A2F37",
                                                      angle: 180))
        result = Pipeline.crop(result, to: CropRect(x: 0, y: 0, width: 1, height: 1))
        result = Pipeline.adjustResolution(result, to: .custom(width: 640, height: 480))
        return result
    }

    // MARK: - Bezel pipeline fixture

    /// Landscape-in + landscape-out variant of `applyBezelPipeline`. Uses a
    /// synthetic bezel since bundled bezels are deferred. On iOS this
    /// exercises the specific L→L flow §S4.2 optimizes: `normalizeToPortrait`
    /// rotates the landscape input to portrait, placeBezel composes with
    /// the portrait bezel, then `applyOrientation` rotates the whole
    /// composition back to landscape. With non-zero offsets the Golden
    /// catches any offset-remapping mistake the optimization might make.
    static func bezelPipelineLandscape() -> PlatformImage {
        let input = syntheticImage(width: 780, height: 360)
        let bezel = syntheticBezel(width: 400, height: 800)
        let params = BezelPipelineParams(
            os: .iOS,
            bezelImage: bezel,
            scale: 0.85,
            verticalOffset: 0.03,
            horizontalOffset: 0.02,
            cornerRadius: 0.04,
            screenshotOnTop: false,
            scaleUpToFill: true,
            orientation: .landscape,
            nativeScreenSize: nil
        )
        return Pipeline.applyBezel(to: input, params: params)
    }

    /// Zoom + pan crop fixture. `crop.width = crop.height = 1.5` with a
    /// non-zero pan exercises the rescale path of `cropImage` (sourceRect
    /// size < imgSize, cropped CGImage needs to be redrawn into the
    /// viewport). Guards §S4.4's fast-path wrap from stealing cases that
    /// actually need the redraw.
    static func cropImageZoomPan() -> PlatformImage {
        let input = syntheticImage(width: 480, height: 320)
        return Pipeline.crop(input, to: CropRect(x: 0.4, y: -0.2, width: 1.5, height: 1.5))
    }

    /// Portrait-in + portrait-out control case for the bezel pipeline —
    /// guards against accidental regressions in the non-rotation path
    /// when §S4.2 adds its iOS/iPadOS L→L special case.
    static func bezelPipelinePortrait() -> PlatformImage {
        let input = syntheticImage(width: 360, height: 780)
        let bezel = syntheticBezel(width: 400, height: 800)
        let params = BezelPipelineParams(
            os: .iOS,
            bezelImage: bezel,
            scale: 0.85,
            verticalOffset: 0.03,
            horizontalOffset: 0.02,
            cornerRadius: 0.04,
            screenshotOnTop: false,
            scaleUpToFill: true,
            orientation: .portrait,
            nativeScreenSize: nil
        )
        return Pipeline.applyBezel(to: input, params: params)
    }
}

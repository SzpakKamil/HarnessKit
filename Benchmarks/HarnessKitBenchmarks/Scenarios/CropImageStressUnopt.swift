//
//  CropImageStressUnopt.swift
//  HarnessKitBenchmarks
//
//  Companion to CropImageStress. Mirrors the pre-§S4.4 cropImage logic:
//  the pan-only call goes through the full-canvas redraw instead of
//  short-circuiting. Kept as a regression witness.
//

import Foundation
import AppKit
import CoreGraphics
import HarnessKitScreenshots
import HarnessKitTransform

final class CropImageStressUnopt: Scenario, @unchecked Sendable {
    let name = "CropImageStressUnopt-4K"
    let iterations = 5

    private var input: PlatformImage!

    func prepare() throws {
        input = SyntheticImage.gradient(width: 3840, height: 2160)
    }

    func run() throws -> PlatformImage? {
        let panned = unoptCropImage(image: input, crop: CropRect(x: 0.3, y: -0.2, width: 1.0, height: 1.0))
        return unoptCropImage(image: panned, crop: CropRect(x: 0.1, y: 0.1, width: 1.5, height: 1.5))
    }

    func teardown() {
        input = nil
    }
}

/// Pre-§S4.4 cropImage behavior: the pan-with-no-zoom case is NOT
/// short-circuited, so it goes through the full-canvas redraw. Lives in
/// the benchmark target only — production callers use the optimized
/// `cropImage` in HarnessKitTransform.
private func unoptCropImage(image: PlatformImage, crop: CropRect) -> PlatformImage {
    if crop.width == 1.0, crop.height == 1.0, crop.x == 0.0, crop.y == 0.0 {
        return image
    }

    let imgSize = image.size
    let viewportSize = imgSize

    let zoomX = CGFloat(crop.width)
    let zoomY = CGFloat(crop.height)

    let sourceWidth = viewportSize.width / zoomX
    let sourceHeight = viewportSize.height / zoomY

    let centerX = imgSize.width / 2
    let centerY = imgSize.height / 2

    let panX = (imgSize.width - sourceWidth) / 2 * CGFloat(crop.x)
    let panY = (imgSize.height - sourceHeight) / 2 * CGFloat(crop.y)

    let sourceRect = CGRect(
        x: centerX - sourceWidth / 2 + panX,
        y: centerY - sourceHeight / 2 + panY,
        width: sourceWidth,
        height: sourceHeight
    )

    let size = NSSize(width: viewportSize.width, height: viewportSize.height)
    return NSImage(size: size, flipped: false) { rect in
        guard let ctx = NSGraphicsContext.current?.cgContext else { return false }
        var r = NSRect(origin: .zero, size: image.size)
        guard let cgImg = image.cgImage(forProposedRect: &r, context: nil, hints: nil) else { return false }
        ctx.interpolationQuality = .high
        guard let cropped = cgImg.cropping(to: CGRect(
            x: sourceRect.origin.x,
            y: imgSize.height - sourceRect.origin.y - sourceRect.height,
            width: sourceRect.width,
            height: sourceRect.height
        )) else { return false }
        ctx.draw(cropped, in: CGRect(origin: .zero, size: viewportSize))
        return true
    }
}

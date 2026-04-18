//
//  SyntheticImage.swift
//  HarnessKitBenchmarks
//
//  Helpers to conjure PlatformImages of arbitrary pixel dimensions. Used as
//  stand-ins for real screenshots so benchmarks don't depend on disk
//  fixtures.
//

import Foundation
import AppKit
import CoreGraphics
import HarnessKitTransform

enum SyntheticImage {
    /// Opaque gradient bitmap at the requested pixel size. Gives the renderer
    /// something non-trivial to blur/mask so filter cost matches real inputs.
    static func gradient(width: Int, height: Int) -> PlatformImage {
        let size = NSSize(width: width, height: height)
        return NSImage(size: size, flipped: false) { rect in
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
    }
}

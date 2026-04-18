import Foundation
import CoreGraphics

/// Draws a linear gradient between two colors at a given angle.
nonisolated func drawLinearGradient(
    in ctx: CGContext,
    rect: CGRect,
    startColor: PlatformColor,
    endColor: PlatformColor,
    angle: CGFloat
) {
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    guard let gradient = CGGradient(
        colorsSpace: colorSpace,
        colors: [startColor.cgColor, endColor.cgColor] as CFArray,
        locations: [0, 1]
    ) else { return }

    let radians = angle * .pi / 180
    let center = CGPoint(x: rect.midX, y: rect.midY)
    let length = max(rect.width, rect.height)
    let start = CGPoint(x: center.x - cos(radians) * length / 2,
                        y: center.y - sin(radians) * length / 2)
    let end = CGPoint(x: center.x + cos(radians) * length / 2,
                      y: center.y + sin(radians) * length / 2)
    ctx.drawLinearGradient(gradient, start: start, end: end, options: [.drawsBeforeStartLocation, .drawsAfterEndLocation])
}

/// Draws a radial gradient from center to edges.
nonisolated func drawRadialGradient(
    in ctx: CGContext,
    rect: CGRect,
    centerColor: PlatformColor,
    edgeColor: PlatformColor
) {
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    guard let gradient = CGGradient(
        colorsSpace: colorSpace,
        colors: [centerColor.cgColor, edgeColor.cgColor] as CFArray,
        locations: [0, 1]
    ) else { return }

    let center = CGPoint(x: rect.midX, y: rect.midY)
    let radius = max(rect.width, rect.height) / 2
    ctx.drawRadialGradient(gradient, startCenter: center, startRadius: 0,
                           endCenter: center, endRadius: radius, options: [])
}

/// Sets a shadow on the given CGContext.
nonisolated func setContextShadow(ctx: CGContext, color: PlatformColor, blur: CGFloat, offset: CGSize) {
    ctx.setShadow(offset: offset, blur: blur, color: color.cgColor)
}

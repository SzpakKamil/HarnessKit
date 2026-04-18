import Foundation
import CoreGraphics
#if canImport(AppKit)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

/// Creates a rounded rect bezier path (cross-platform).
nonisolated func makeRoundedRectPath(rect: CGRect, xRadius: CGFloat, yRadius: CGFloat) -> PlatformBezierPath {
    #if canImport(AppKit)
    return NSBezierPath(roundedRect: rect, xRadius: xRadius, yRadius: yRadius)
    #else
    return UIBezierPath(roundedRect: rect, cornerRadius: min(xRadius, yRadius))
    #endif
}

/// Creates an oval bezier path.
nonisolated func makeOvalPath(in rect: CGRect) -> PlatformBezierPath {
    #if canImport(AppKit)
    return NSBezierPath(ovalIn: rect)
    #else
    return UIBezierPath(ovalIn: rect)
    #endif
}

/// Creates a rect bezier path.
nonisolated func makeRectPath(_ rect: CGRect) -> PlatformBezierPath {
    #if canImport(AppKit)
    return NSBezierPath(rect: rect)
    #else
    return UIBezierPath(rect: rect)
    #endif
}

/// Adds a line to a bezier path (cross-platform).
nonisolated func pathAddLine(_ path: PlatformBezierPath, to point: CGPoint) {
    #if canImport(AppKit)
    path.line(to: point)
    #else
    path.addLine(to: point)
    #endif
}

/// Adds an arc to a bezier path.
nonisolated func pathAddArc(_ path: PlatformBezierPath, center: CGPoint, radius: CGFloat, startAngle: CGFloat, endAngle: CGFloat) {
    #if canImport(AppKit)
    path.appendArc(withCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle)
    #else
    path.addArc(withCenter: center, radius: radius, startAngle: startAngle * .pi / 180, endAngle: endAngle * .pi / 180, clockwise: false)
    #endif
}

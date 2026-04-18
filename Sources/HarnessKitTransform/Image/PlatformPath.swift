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

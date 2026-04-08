//
//  ScreenshotShadow.swift
//  HarnessKitScreenshots
//

import Foundation

/// A single shadow effect applied to a screenshot.
/// Multiple shadows can be stacked per screenshot.
public enum ScreenshotShadow: Codable, Hashable, Sendable {
    /// Drop shadow that follows the device bezel's alpha shape.
    case drop(DropShadow)
    /// Independent shape shadow placed relative to the device (e.g. contact shadow ellipse).
    case shape(ShapeShadow)
}

/// Standard drop shadow matching the bezel silhouette.
/// All values are fractions of the device's short side for resolution-independent sizing.
public struct DropShadow: Codable, Hashable, Sendable {
    /// Shadow color as hex (e.g. "000000").
    public var color: String
    /// Opacity 0–1.
    public var opacity: Double
    /// Blur radius as fraction of device short side.
    public var blur: Double
    /// Horizontal offset as fraction of device short side.
    public var offsetX: Double
    /// Vertical offset as fraction of device short side.
    public var offsetY: Double

    public init(color: String = "000000", opacity: Double = 0.5, blur: Double = 0.02, offsetX: Double = 0, offsetY: Double = 0.01) {
        self.color = color
        self.opacity = opacity
        self.blur = blur
        self.offsetX = offsetX
        self.offsetY = offsetY
    }
}

/// A standalone shape shadow drawn independently of the device image.
/// All values are fractions of the device's short side for resolution-independent sizing.
public struct ShapeShadow: Codable, Hashable, Sendable {
    /// Shadow color as hex (e.g. "000000").
    public var color: String
    /// Opacity 0–1.
    public var opacity: Double
    /// Blur radius as fraction of device short side.
    public var blur: Double
    /// Horizontal center offset as fraction of device short side (0 = centered).
    public var x: Double
    /// Vertical center offset as fraction of device short side (0 = centered).
    public var y: Double
    /// Width as fraction of device short side.
    public var width: Double
    /// Height as fraction of device short side.
    public var height: Double
    /// Corner radius factor 0–1 (0 = rectangle, 1 = full ellipse).
    public var cornerRadius: Double

    public init(
        color: String = "000000", opacity: Double = 0.3, blur: Double = 0.06,
        x: Double = 0, y: Double = -1.1,
        width: Double = 1.7, height: Double = 0.025,
        cornerRadius: Double = 1
    ) {
        self.color = color
        self.opacity = opacity
        self.blur = blur
        self.x = x
        self.y = y
        self.width = width
        self.height = height
        self.cornerRadius = cornerRadius
    }
}

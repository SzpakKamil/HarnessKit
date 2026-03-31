//
//  CropRect.swift
//  HarnessKitScreenshots
//

import Foundation

public struct CropRect: Codable, Hashable, Sendable {
    /// X pan offset, normalized (-1.0 to 1.0)
    public var x: Double

    /// Y pan offset, normalized (-1.0 to 1.0)
    public var y: Double

    /// Width as zoom factor (1.0 = no zoom)
    public var width: Double

    /// Height as zoom factor (1.0 = no zoom)
    public var height: Double

    public init(x: Double, y: Double, width: Double, height: Double) {
        self.x = x
        self.y = y
        self.width = width
        self.height = height
    }
}

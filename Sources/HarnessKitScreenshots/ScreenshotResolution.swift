//
//  ScreenshotResolution.swift
//  HarnessKitScreenshots
//

import Foundation
import CoreGraphics

public enum ScreenshotResolution: String, Codable, Sendable {
    case full
    case `default`

    public var size: CGSize {
        switch self {
        case .full:
            CGSize(width: 2089, height: 1440)
        case .default:
            CGSize(width: 603, height: 416)
        }
    }

    public static func option(for name: String) -> ScreenshotResolution {
        switch name {
        case "full":
            return .full
        case "default":
            return .default
        default:
            fatalError("Unknown resolution: \(name)")
        }
    }
}

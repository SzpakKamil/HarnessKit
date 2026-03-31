//
//  OtherBezel.swift
//  HarnessKitTransform
//

import Foundation

public enum OtherBezel: BezelDescriptor {
    // ============ Apple TV 4k =================
    case `Apple TV Frame`

    public var id: String {
        switch self {
        case .`Apple TV Frame`: return "AppleTVFrame"
        }
    }

    public var model: String {
        switch self {
        case .`Apple TV Frame`: return "Apple TV"
        }
    }

    public var shortID: String {
        switch self {
        case .`Apple TV Frame`: return "AppleTVFrame"
        }
    }

    public var prettyName: String {
        switch self {
        case .`Apple TV Frame`: return "Apple TV Frame"
        }
    }

    public var runDestination: String {
        switch self {
        case .`Apple TV Frame`: return "Apple TV 4K (3rd Generation)"
        }
    }

    public var scale: CGFloat {
        switch self {
        case .`Apple TV Frame`: return 0.995
        }
    }

    public var verticalOffset: CGFloat {
        switch self {
        case .`Apple TV Frame`: return 0
        }
    }
}

//
//  TargetOS.swift
//  HarnessKitScreenshots
//

import SwiftUI
import Foundation

public enum TargetOS: String, Identifiable, Sendable, Codable, Hashable, CaseIterable, Equatable {
    case macOSTahoe = "macOSTahoe"
    case macOSSequoia = "macOSSequoia"
    case iOS = "iOS"
    case iPadOS = "iPadOS"
    case watchOS = "watchOS"
    case tvOS = "tvOS"
    case visionOS = "visionOS"

    public var id: String {
        rawValue
    }

    public var isMacOS: Bool {
        return id.contains("macOS")
    }

    public static var newestMacOS: TargetOS {
        return .macOSTahoe
    }

    public static var currentOS: TargetOS {
        #if os(iOS)
        return UIDevice.current.userInterfaceIdiom == .phone ? .iOS : .iPadOS
        #elseif os(watchOS)
        return .watchOS
        #elseif os(tvOS)
        return .tvOS
        #elseif os(macOS)
        return newestMacOS
        #else
        return .visionOS
        #endif
    }
}

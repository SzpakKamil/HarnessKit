import SwiftUI
import Foundation

public enum TargetOS: String, Identifiable, Sendable, Codable, Hashable, CaseIterable, Equatable {
    case macOS = "macOS"
    case iOS = "iOS"
    case iPadOS = "iPadOS"
    case watchOS = "watchOS"
    case tvOS = "tvOS"
    case visionOS = "visionOS"

    public var id: String {
        rawValue
    }

    public var isMacOS: Bool {
        return self == .macOS
    }

    public static var currentOS: TargetOS {
        #if os(iOS)
        return UIDevice.current.userInterfaceIdiom == .phone ? .iOS : .iPadOS
        #elseif os(watchOS)
        return .watchOS
        #elseif os(tvOS)
        return .tvOS
        #elseif os(macOS)
        return .macOS
        #else
        return .visionOS
        #endif
    }
}

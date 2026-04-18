import Foundation
import HarnessKitScreenshots
#if canImport(XCTest)
import XCTest

/// Sets the device appearance (light/dark) for UI tests.
@available(macOS 12.0, iOS 15.0, tvOS 15.0, visionOS 1.0, watchOS 10.0, *)
public func resetTheme(to appearance: XCUIDevice.Appearance) {
    #if !os(watchOS)
    XCUIDevice.shared.appearance = appearance
    #endif
}

/// Returns the current device appearance used during UI tests.
@available(macOS 12.0, iOS 15.0, tvOS 15.0, visionOS 1.0, watchOS 10.0, *)
public func currentTheme() -> XCUIDevice.Appearance {
    #if os(watchOS)
    return .unspecified
    #else
    return XCUIDevice.Appearance(
        rawValue: XCUIDevice.shared.appearance.rawValue
    ) ?? .unspecified
    #endif
}

#endif

import Foundation
import HarnessKitScreenshots
#if canImport(XCTest)
import XCTest

/// Sets the device orientation for iOS UI tests.
///
/// - Parameters:
///   - phone: Orientation for iPhone idiom. Defaults to `.portrait`.
///   - pad: Orientation for iPad idiom. Defaults to `.landscape`.
@MainActor
public func updateOrientation(
    phone: ScreenOrientation = .portrait,
    pad: ScreenOrientation = .landscape
) {
    #if os(iOS)
    XCUIDevice.shared.orientation = UIDevice.current.userInterfaceIdiom == .phone
        ? phone.uiKitValue
        : pad.uiKitValue
    sleep(2)
    #endif
}

@MainActor
public func setOrientation(to orientation: ScreenOrientation) {
    #if os(iOS)
    XCUIDevice.shared.orientation = orientation.uiKitValue
    sleep(2)
    #endif
}

#endif

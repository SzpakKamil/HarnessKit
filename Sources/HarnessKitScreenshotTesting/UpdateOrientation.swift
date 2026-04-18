import Foundation
import HarnessKitScreenshots
#if canImport(XCTest)
import XCTest

/// Sets the device orientation for iOS UI tests based on the given config.
///
/// - Parameter config: The screenshot config to read orientation from.
///   Defaults to `.defaults` if not provided.
@MainActor
public func updateOrientation(config: ScreenshotConfig = .defaults) {
    #if os(iOS)
    XCUIDevice.shared.orientation = UIDevice.current.userInterfaceIdiom == .phone
        ? config.phoneOrientation.uiKitValue
        : config.padOrientation.uiKitValue
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

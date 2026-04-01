//
//  UpdateOrientation.swift
//  HarnessKitScreenshots
//

import Foundation
#if canImport(XCTest)
import XCTest

/// Sets the device orientation for iOS UI tests based on the global config.
@MainActor
public func updateOrientation() {
    #if os(iOS)
    let config = ScreenshotConfig.load()
    XCUIDevice.shared.orientation = UIDevice.current.userInterfaceIdiom == .phone
        ? config.phoneOrientation.uiKitValue
        : config.padOrientation.uiKitValue
    sleep(2)
    #endif
}

@MainActor
public func setOrientation(to orientation: UIDeviceOrientation) {
    #if os(iOS)
    XCUIDevice.shared.orientation = orientation
    sleep(2)
    #endif
}

#endif

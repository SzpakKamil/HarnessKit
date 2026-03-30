//
//  HarnessPreviewNavigation.swift
//  HarnessKit
//
//  Created by Kamil Szpak on 29/03/2026.
//

import XCTest
import HarnessKit

extension PathFolder {
    @MainActor
    public func advancePreview(app: XCUIApplication) {
        advancePreview(app: app, steps: 1)
    }

    @MainActor
    public func advancePreview(app: XCUIApplication, steps: Int) {
        for _ in 0..<steps {
#if os(tvOS)
            XCUIRemote.shared.press(.playPause)
            sleep(1)
#elseif os(macOS)
            app.otherElements["HarnessPreview"].firstMatch.click()
#else
            app.otherElements["HarnessPreview"].firstMatch.tap()
#endif
        }
    }

    @MainActor
    public func iteratePreview(
        app: XCUIApplication,
        variantCount: Int,
        action: (Int) -> Void
    ) {
        navigate(app: app)
        for index in 0..<variantCount {
            action(index)
            if index < variantCount - 1 {
                advancePreview(app: app)
            }
        }
    }
}

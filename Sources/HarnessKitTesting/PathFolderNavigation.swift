import XCTest
import HarnessKit

extension PathFolder {
    @MainActor
    public func navigate(app: XCUIApplication) {
        #if !os(macOS) && !os(tvOS)
        for name in Self.names(forType: Self.self) {
            tapButtonWithScrolling(app: app, titleOrIdentifier: name)
        }
        #elseif os(macOS)
        for name in Self.names(forType: Self.self) {
            clickButtonWithScrolling(app: app, titleOrIdentifier: name)
        }
        #else
        fatalError("Not supported on tvOS types without RawRepresentable")
        #endif
    }
}

extension PathFolder where Self: RawRepresentable, RawValue == Int {
    @MainActor
    public func navigate(app: XCUIApplication) {
        #if !os(macOS) && !os(tvOS)
        for name in Self.names(for: self) {
            tapButtonWithScrolling(app: app, titleOrIdentifier: name)
        }
        #elseif os(macOS)
        for name in Self.names(for: self) {
            clickButtonWithScrolling(app: app, titleOrIdentifier: name)
        }
        #else
        app.activate()
        for id in Self.pathIds {
            for _ in 0..<id {
                XCUIRemote.shared.press(.down)
            }
            XCUIRemote.shared.press(.select)
            sleep(1)
        }
        let optionRow = Self.folders.count + self.rawValue
        for _ in 0..<optionRow {
            XCUIRemote.shared.press(.down)
        }
        XCUIRemote.shared.press(.select)
        sleep(1)
        #endif
    }
}

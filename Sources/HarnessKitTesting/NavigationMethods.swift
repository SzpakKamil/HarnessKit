import XCTest

#if os(iOS) || os(watchOS)
@MainActor
func smallSwipeUp(on element: XCUIElement, distanceRatio: CGFloat = 0.2, hold: TimeInterval = 0.01) {
#if os(watchOS)
    XCUIDevice.shared.rotateDigitalCrown(delta: 0.2, velocity: 0.24)
    sleep(1)
#else
    guard element.exists else { return }
    let start = element.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.7))
    let dy = max(0.02, min(0.9, distanceRatio))
    let end = element.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.7 - dy))
    start.press(forDuration: hold, thenDragTo: end)
#endif
}

@MainActor
func smallSwipeUp(app: XCUIApplication, distanceRatio: CGFloat = 0.2, hold: TimeInterval = 0.01) {
    let target = app.tables.firstMatch.exists ? app.tables.firstMatch
               : app.collectionViews.firstMatch.exists ? app.collectionViews.firstMatch
               : app.scrollViews.firstMatch.exists ? app.scrollViews.firstMatch
               : app.windows.firstMatch
    smallSwipeUp(on: target, distanceRatio: distanceRatio, hold: hold)
}

@MainActor
public func tapButtonWithScrolling(app: XCUIApplication, titleOrIdentifier: String, maxSwipes: Int = 40) {
    var button = app.buttons[titleOrIdentifier]
    if button.exists && button.isHittable {
        button.tap()
        return
    }
    let predicate = NSPredicate(format: "label == %@ OR identifier == %@", titleOrIdentifier, titleOrIdentifier)
    button = app.buttons.matching(predicate).firstMatch

    let scrollable = app.tables.firstMatch.exists ? app.tables.firstMatch
                    : app.collectionViews.firstMatch.exists ? app.collectionViews.firstMatch
                    : app.scrollViews.firstMatch

    var attempts = 0
    while (!button.exists || !button.isHittable) && attempts < maxSwipes {
        if scrollable.exists {
            smallSwipeUp(on: scrollable, distanceRatio: 0.18)
        } else {
            smallSwipeUp(app: app, distanceRatio: 0.18)
        }
        attempts += 1
        RunLoop.current.run(until: Date().addingTimeInterval(0.05))
    }

    if button.exists {
        if button.isHittable {
            button.tap()
        } else {
            if scrollable.exists {
                let start = scrollable.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
                let down = scrollable.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.65))
                down.press(forDuration: 0.01, thenDragTo: start)
                smallSwipeUp(on: scrollable, distanceRatio: 0.12)
            } else {
                smallSwipeUp(app: app, distanceRatio: 0.12)
            }
            if button.isHittable {
                button.tap()
            } else {
                XCTFail("Failed to tap \"\(titleOrIdentifier)\" Button after scrolling.")
            }
        }
    } else {
        XCTFail("Button \"\(titleOrIdentifier)\" not found after \(maxSwipes) scroll attempts.")
    }
}
#endif

#if os(macOS)
@MainActor
public func clickButtonWithScrolling(app: XCUIApplication, titleOrIdentifier: String, maxScrolls: Int = 20) {
    var button = app.buttons[titleOrIdentifier]
    if button.exists && button.isHittable {
        button.click()
        return
    }
    let predicate = NSPredicate(format: "label == %@ OR identifier == %@", titleOrIdentifier, titleOrIdentifier)
    button = app.buttons.matching(predicate).firstMatch

    let scrollView = app.scrollViews.firstMatch
    var attempts = 0
    while (!button.exists || !button.isHittable) && attempts < maxScrolls {
        if scrollView.exists {
            scrollView.scroll(byDeltaX: 0, deltaY: -2)
        } else {
            app.typeKey(.pageDown, modifierFlags: [])
        }
        attempts += 1
        RunLoop.current.run(until: Date().addingTimeInterval(0.05))
    }

    if button.exists && button.isHittable {
        button.click()
    } else {
        XCTFail("Failed to click \"\(titleOrIdentifier)\" Button after scrolling.")
    }
}
#endif

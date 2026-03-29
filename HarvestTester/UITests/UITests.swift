//
//  UITests.swift
//  UITests
//

import XCTest
import HarnessKit
import HarnessKitTesting

@MainActor private enum DemoProject: PathProject {
    static let name = "Demo"
    static let folders: [any PathFolder.Type] = [ShapesSection.self, ColorsSection.self]
}

@MainActor private enum ShapesSection: PathFolder {
    typealias ParentSection = DemoProject
    static let name = "Shapes"
    static let folders: [any PathFolder.Type] = [BasicShapes.self]
}

@MainActor private enum ColorsSection: PathFolder {
    typealias ParentSection = DemoProject
    static let name = "Colors"
    static let folders: [any PathFolder.Type] = [PrimaryColors.self]
}

@MainActor private enum BasicShapes: Int, PathFolder, CaseIterable {
    case circle, square
    typealias ParentSection = ShapesSection
    static let name = "BasicShapes"
    static let folders: [any PathFolder.Type] = [AdvancedShapes.self]
    var description: String { String(describing: self) }
}

@MainActor private enum AdvancedShapes: Int, PathFolder, CaseIterable {
    case pentagon, hexagon
    typealias ParentSection = BasicShapes
    static let name = "AdvancedShapes"
    static let folders: [any PathFolder.Type] = []
    var description: String { String(describing: self) }
}

@MainActor private enum PrimaryColors: Int, PathFolder, CaseIterable {
    case red, blue
    typealias ParentSection = ColorsSection
    static let name = "PrimaryColors"
    static let folders: [any PathFolder.Type] = []
    var description: String { String(describing: self) }
}

// MARK: - Helpers
private extension PathFolder where Self: RawRepresentable, RawValue == Int {
    var expectedIdentifier: String { namePath }
}

// MARK: - Tests

final class NavigateTests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: ColorsSection — folder at root index 1, options with no sub-folder offset
    @MainActor func testNavigateToRed() throws {
        PrimaryColors.red.navigate(app: app)
        XCTAssertTrue(
            app.staticTexts[PrimaryColors.red.expectedIdentifier].waitForExistence(timeout: 3),
            "Should land on PrimaryColors.red destination"
        )
    }

    @MainActor func testNavigateToBlue() throws {
        PrimaryColors.blue.navigate(app: app)
        XCTAssertTrue(
            app.staticTexts[PrimaryColors.blue.expectedIdentifier].waitForExistence(timeout: 3),
            "Should land on PrimaryColors.blue destination"
        )
    }

    // MARK: BasicShapes — sub-folder present, option rows are offset by 1
    @MainActor func testNavigateToCircle() throws {
        BasicShapes.circle.navigate(app: app)
        XCTAssertTrue(
            app.staticTexts[BasicShapes.circle.expectedIdentifier].waitForExistence(timeout: 3),
            "Should land on BasicShapes.circle destination (row offset by AdvancedShapes sub-folder)"
        )
    }

    @MainActor func testNavigateToSquare() throws {
        BasicShapes.square.navigate(app: app)
        XCTAssertTrue(
            app.staticTexts[BasicShapes.square.expectedIdentifier].waitForExistence(timeout: 3),
            "Should land on BasicShapes.square destination"
        )
    }

    // MARK: AdvancedShapes — three levels deep
    @MainActor func testNavigateToPentagon() throws {
        AdvancedShapes.pentagon.navigate(app: app)
        XCTAssertTrue(
            app.staticTexts[AdvancedShapes.pentagon.expectedIdentifier].waitForExistence(timeout: 3),
            "Should land on AdvancedShapes.pentagon destination"
        )
    }

    @MainActor func testNavigateToHexagon() throws {
        AdvancedShapes.hexagon.navigate(app: app)
        XCTAssertTrue(
            app.staticTexts[AdvancedShapes.hexagon.expectedIdentifier].waitForExistence(timeout: 3),
            "Should land on AdvancedShapes.hexagon destination"
        )
    }
}

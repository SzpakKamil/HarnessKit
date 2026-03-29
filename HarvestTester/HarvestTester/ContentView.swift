//
//  ContentView.swift
//  HarvestTester
//

import SwiftUI
import HarnessKit

@MainActor
enum DemoProject: PathProject {
    static let name = "Demo"
    static let folders: [any PathFolder.Type] = [ShapesSection.self, ColorsSection.self]
}

@MainActor
enum ShapesSection: PathFolder {
    typealias ParentSection = DemoProject
    static let name = "Shapes"
    static let folders: [any PathFolder.Type] = [BasicShapes.self]
}

@MainActor
enum ColorsSection: PathFolder {
    typealias ParentSection = DemoProject
    static let name = "Colors"
    static let folders: [any PathFolder.Type] = [PrimaryColors.self]
}

/// Has one sub-folder (AdvancedShapes) plus two option cases.
/// On tvOS, option rows are offset by 1 because AdvancedShapes occupies row 0.
@MainActor
enum BasicShapes: Int, PathFolder, CaseIterable {
    case circle
    case square

    typealias ParentSection = ShapesSection
    static let name = "BasicShapes"
    static let folders: [any PathFolder.Type] = [AdvancedShapes.self]

    var description: String { String(describing: self) }
    var view: AnyView? {
        AnyView(
            Text(String(describing: self))
                .accessibilityIdentifier(namePath)
        )
    }
}

@MainActor
enum AdvancedShapes: Int, PathFolder, CaseIterable {
    case pentagon
    case hexagon

    typealias ParentSection = BasicShapes
    static let name = "AdvancedShapes"
    static let folders: [any PathFolder.Type] = []

    var description: String { String(describing: self) }
    var view: AnyView? {
        AnyView(
            Text(String(describing: self))
                .accessibilityIdentifier(namePath)
        )
    }
}

@MainActor
enum PrimaryColors: Int, PathFolder, CaseIterable {
    case red
    case blue

    typealias ParentSection = ColorsSection
    static let name = "PrimaryColors"
    static let folders: [any PathFolder.Type] = []

    var description: String { String(describing: self) }
    var view: AnyView? {
        AnyView(
            Text(String(describing: self))
                .accessibilityIdentifier(namePath)
        )
    }
}

// MARK: - Root view

struct ContentView: View {
    var body: some View {
        HarnessView<DemoProject>()
    }
}

#Preview {
    ContentView()
}

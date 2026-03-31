//
//  PathFolder.swift
//  HarnessKit
//
//  Created by Kamil Szpak on 29/03/2026.
//

import Foundation
import SwiftUI

@MainActor
public protocol PathFolder: PathProject, CaseIterable {
    associatedtype ParentSection: PathProject
    static var options: [any PathFolder] { get }
    associatedtype Content: View
    var description: String { get }
    @ViewBuilder var view: Content { get }
}

extension PathFolder {
    internal static var path: Int {
        ParentSection.folders.firstIndex(where: { ObjectIdentifier($0) == ObjectIdentifier(Self.self) }) ?? 0
    }
    @_documentation(visibility: internal)
    public static var pathIds: [Int] { ParentSection.pathIds + [path] }
    @_documentation(visibility: internal)
    public static var nameComponents: [String] { ParentSection.nameComponents + [name] }
    @_documentation(visibility: internal)
    public static var namePath: String { nameComponents.joined(separator: "/") }
    @_documentation(visibility: internal)
    public static var folders: [any PathFolder.Type] { [] }
    @_documentation(visibility: internal)
    public static var options: [any PathFolder] { Array(allCases) }
    @_documentation(visibility: internal)
    public var description: String { "" }
    @_documentation(visibility: internal)
    public var view: some View { EmptyView() }
}

extension PathFolder where Self: RawRepresentable, RawValue == Int {
    @_documentation(visibility: internal)
    public var pathIds: [Int] { Self.pathIds + [self.rawValue] }

    private var caseName: String {
        Mirror(reflecting: self).children.first?.label ?? String(describing: self)
    }

    @_documentation(visibility: internal)
    public var nameComponents: [String] { Self.nameComponents + [caseName] }
    @_documentation(visibility: internal)
    public var namePath: String { nameComponents.joined(separator: "/") }
}

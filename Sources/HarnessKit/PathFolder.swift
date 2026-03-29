import Foundation
import SwiftUI

@MainActor
public protocol PathFolder: CaseIterable, Sendable {
    associatedtype ParentSection
    static var name: String { get }
    static var pathIds: [Int] { get }
    static var nameComponents: [String] { get }
    static var namePath: String { get }
    static var folders: [any PathFolder.Type] { get }
    static var options: [any PathFolder] { get }
    var description: String { get }
    var view: AnyView? { get }
}

extension PathFolder {
    public static var options: [any PathFolder] { Array(allCases) }
    public var description: String { "" }
    public var view: AnyView? { nil }
}

extension PathFolder where ParentSection: PathProject {
    public static var path: Int {
        ParentSection.folders.firstIndex(where: { ObjectIdentifier($0) == ObjectIdentifier(Self.self) }) ?? 0
    }
    public static var pathIds: [Int] { ParentSection.pathIds + [path] }
    public static var nameComponents: [String] { ParentSection.nameComponents + [name] }
    public static var namePath: String { nameComponents.joined(separator: "/") }
}

extension PathFolder where ParentSection: PathFolder {
    public static var path: Int {
        ParentSection.folders.firstIndex(where: { ObjectIdentifier($0) == ObjectIdentifier(Self.self) }) ?? 0
    }
    public static var pathIds: [Int] { ParentSection.pathIds + [path] }
    public static var nameComponents: [String] { ParentSection.nameComponents + [name] }
    public static var namePath: String { nameComponents.joined(separator: "/") }
}

extension PathFolder where Self: RawRepresentable, RawValue == Int {
    public var pathIds: [Int] { Self.pathIds + [self.rawValue] }

    private var caseName: String {
        Mirror(reflecting: self).children.first?.label ?? String(describing: self)
    }

    public var nameComponents: [String] { Self.nameComponents + [caseName] }
    public var namePath: String { nameComponents.joined(separator: "/") }
}

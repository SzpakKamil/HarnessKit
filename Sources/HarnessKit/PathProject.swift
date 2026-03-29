import Foundation

/// Root of a view path hierarchy. Has no parent and contributes no id/name components.
@MainActor
public protocol PathProject: Sendable {
    static var name: String { get }
    static var pathIds: [Int] { get }
    static var nameComponents: [String] { get }
    static var namePath: String { get }
    static var folders: [any PathFolder.Type] { get }
}

extension PathProject {
    public static var pathIds: [Int] { [] }
    public static var nameComponents: [String] { [] }
    public static var namePath: String { nameComponents.joined(separator: "/") }
}

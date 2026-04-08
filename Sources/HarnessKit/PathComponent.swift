//
//  PathComponent.swift
//  HarnessKit
//
//  Created by Kamil Szpak on 02/04/2026.
//

import Foundation

@MainActor
public protocol PathComponent: Sendable {
    static var folders: [any PathFolder.Type] { get }
    static var options: [any PathFolder] { get }
    static var pathIds: [Int] { get }
    static var nameComponents: [String] { get }
}

public extension PathComponent {
    @_documentation(visibility: internal)
    static var options: [any PathFolder] { [] }
}

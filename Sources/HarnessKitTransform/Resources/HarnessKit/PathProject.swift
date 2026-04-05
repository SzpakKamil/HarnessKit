//
//  PathProject.swift
//  HarnessKit
//
//  Created by Kamil Szpak on 29/03/2026.
//


import Foundation
import SwiftUI

@MainActor
public protocol PathProject: Sendable, PathComponent {
    static var name: String { get }
    static var pathIds: [Int] { get }
    static var nameComponents: [String] { get }
    static var namePath: String { get }
    static var folders: [any PathFolder.Type] { get }
}

extension PathProject {
    @_documentation(visibility: internal)
    public static var folders: [any PathFolder.Type] { [] }
    @_documentation(visibility: internal)
    public static var pathIds: [Int] { [] }
    @_documentation(visibility: internal)
    public static var nameComponents: [String] { [] }
    @_documentation(visibility: internal)
    public static var namePath: String { nameComponents.joined(separator: "/") }
}

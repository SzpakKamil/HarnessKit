//
//  PathComponent.swift
//  HarnessKit
//
//  Created by Kamil Szpak on 02/04/2026.
//

import Foundation

@MainActor
public protocol PathComponent {
    static var folders: [any PathFolder.Type] { get }
    static var pathIds: [Int] { get }
    static var nameComponents: [String] { get }
}

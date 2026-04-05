//
//  PathResolver.swift
//  HarnessKit
//
//  Created by Kamil Szpak on 29/03/2026.
//


import Foundation

extension PathFolder {
    public static func ids<N: PathFolder & RawRepresentable>(for node: N) -> [Int] where N.RawValue == Int {
        node.pathIds
    }
    public static func names<N: PathFolder & RawRepresentable>(for node: N) -> [String] where N.RawValue == Int {
        node.nameComponents
    }
    public static func namePath<N: PathFolder & RawRepresentable>(for node: N) -> String where N.RawValue == Int {
        node.namePath
    }

    public static func ids<N: PathFolder>(forType type: N.Type) -> [Int] {
        N.pathIds
    }
    public static func names<N: PathFolder>(forType type: N.Type) -> [String] {
        N.nameComponents
    }
    public static func namePath<N: PathFolder>(forType type: N.Type) -> String {
        N.namePath
    }
}

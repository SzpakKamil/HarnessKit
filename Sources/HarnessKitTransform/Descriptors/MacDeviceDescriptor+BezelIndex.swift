//
//  MacDeviceDescriptor+BezelIndex.swift
//  HarnessKitTransform
//
//  Bezel filename index cache for Mac bezels (key*value^key*value convention).
//

import Foundation
import AppKit

// MARK: - Parsed bezel filename

/// A bezel filename parsed from the Screenshot-style `key*value^key*value` convention.
/// The loader builds an index of all such files once and uses it to resolve requests.
struct ParsedBezelName {
    let device: String
    let size: String
    let models: Set<String>
    let color: String
    let osMajor: String
    let wallpaper: String
    let appearance: String

    static func parse(_ filename: String) -> ParsedBezelName? {
        let fields = parseKeyedFilename(filename)
        guard
            let device    = fields["device"],
            let size      = fields["size"],
            let modelsRaw = fields["models"],
            let color     = fields["color"],
            let osMajor   = fields["os"],
            let wallpaper = fields["wallpaper"],
            let appearance = fields["appearance"]
        else { return nil }

        return ParsedBezelName(
            device: device,
            size: size,
            models: Set(modelsRaw.split(separator: "+").map(String.init)),
            color: color,
            osMajor: osMajor,
            wallpaper: wallpaper,
            appearance: appearance
        )
    }

    /// Index of every `ParsedBezelName`-compatible PNG available right now.
    /// Recomputed whenever `CatalogueStore.shared.generation` changes.
    static var index: [(parsed: ParsedBezelName, url: URL)] {
        macIndexCache.current()
    }
}

private let macIndexCache = GenerationCache {
    buildBezelIndex(prefix: RemotePath.macBezelPrefix, parse: ParsedBezelName.parse, resolveURL: macBezelURL)
}

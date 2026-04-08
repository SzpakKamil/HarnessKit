//
//  WatchDeviceDescriptor+BezelIndex.swift
//  HarnessKitTransform
//
//  Bezel filename index cache for Apple Watch bezels.
//

import Foundation
import AppKit

// MARK: - Parsed watch bezel filename

struct ParsedWatchBezelName {
    let series: String
    let size: String
    let material: String
    let color: String
    let band: String

    static func parse(_ filename: String) -> ParsedWatchBezelName? {
        let fields = parseKeyedFilename(filename)
        guard
            fields["device"] == "AppleWatch",
            let series   = fields["series"],
            let size     = fields["size"],
            let material = fields["material"],
            let color    = fields["color"],
            let band     = fields["band"]
        else { return nil }

        return ParsedWatchBezelName(series: series, size: size, material: material, color: color, band: band)
    }

    static var index: [(parsed: ParsedWatchBezelName, url: URL)] {
        watchIndexCache.current()
    }
}

private let watchIndexCache = GenerationCache {
    buildBezelIndex(prefix: RemotePath.watchBezelPrefix, parse: ParsedWatchBezelName.parse, resolveURL: watchBezelURL)
}

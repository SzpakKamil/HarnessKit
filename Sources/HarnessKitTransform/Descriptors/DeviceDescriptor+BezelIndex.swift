//
//  DeviceDescriptor+BezelIndex.swift
//  HarnessKitTransform
//
//  Bezel filename index caches for iPad (processor-set) and TV (generation-set) bezels.
//

import Foundation
import AppKit

// MARK: - Shared bezel index builder

/// Builds a bezel index from manifest paths (primary) or bundle PNGs (fallback).
/// Shared by all platform-specific bezel index caches.
func buildBezelIndex<T>(
    prefix: String,
    parse: (String) -> T?,
    resolveURL: (String) -> URL?
) -> [(parsed: T, url: URL)] {
    let manifestPaths = CatalogueStore.shared.filePaths(withPrefix: prefix)
    if !manifestPaths.isEmpty {
        return manifestPaths.compactMap { relativePath in
            let filename = (relativePath as NSString).lastPathComponent
            guard let parsed = parse(filename) else { return nil }
            guard let url = resolveURL(relativePath) else { return nil }
            return (parsed, url)
        }
    }
    guard let urls = Bundle.module.urls(forResourcesWithExtension: "png", subdirectory: nil) else {
        return []
    }
    return urls.compactMap { url in
        guard let parsed = parse(url.lastPathComponent) else { return nil }
        return (parsed, url)
    }
}

/// Resolves a bezel URL from cache first, then bundle fallback.
func defaultBezelURL(relativePath: String) -> URL? {
    if let cached = CatalogueStore.shared.cachedBezelURL(relativePath: relativePath) {
        return cached
    }
    let filename = (relativePath as NSString).lastPathComponent
    let base = (filename as NSString).deletingPathExtension
    return Bundle.module.url(forResource: base, withExtension: "png")
}

// MARK: - Parsed pad bezel filename (processor-set convention)

/// A pad bezel filename parsed from the `key*value^key*value` convention.
/// Used to resolve requests for iPad descriptors whose `id` encodes a chip suffix.
///
/// Example file: `device*iPadAir11^processors*M2+M3+M4^color*Blue.png`
struct ParsedPadBezelName {
    let device: String
    let processors: Set<String>
    let color: String

    static func parse(_ filename: String) -> ParsedPadBezelName? {
        let fields = parseKeyedFilename(filename)
        guard
            let device   = fields["device"],
            let procsRaw = fields["processors"],
            let color    = fields["color"]
        else { return nil }
        return ParsedPadBezelName(
            device:     device,
            processors: Set(procsRaw.split(separator: "+").map(String.init)),
            color:      color
        )
    }

    static var index: [(parsed: ParsedPadBezelName, url: URL)] {
        padIndexCache.current()
    }
}

private let padIndexCache = GenerationCache {
    buildBezelIndex(prefix: RemotePath.padBezelPrefix, parse: ParsedPadBezelName.parse, resolveURL: defaultBezelURL)
}

// MARK: - Parsed TV bezel filename (generation-set convention)

/// A TV bezel filename parsed from `device*{id}^gens*{g1+g2+...}^color*{color}.png`.
/// Also handles simpler `device*{id}^color*{color}.png` (no gens key).
struct ParsedTVBezelName {
    let device: String
    let generations: Set<String>
    let color: String

    static func parse(_ filename: String) -> ParsedTVBezelName? {
        let fields = parseKeyedFilename(filename)
        guard
            let device = fields["device"],
            let color  = fields["color"]
        else { return nil }
        let gens: Set<String>
        if let gensRaw = fields["gens"] {
            gens = Set(gensRaw.split(separator: "+").map(String.init))
        } else {
            gens = []
        }
        return ParsedTVBezelName(device: device, generations: gens, color: color)
    }

    static var index: [(parsed: ParsedTVBezelName, url: URL)] {
        tvIndexCache.current()
    }
}

private let tvIndexCache = GenerationCache {
    buildBezelIndex(prefix: RemotePath.tvBezelPrefix, parse: ParsedTVBezelName.parse, resolveURL: defaultBezelURL)
}

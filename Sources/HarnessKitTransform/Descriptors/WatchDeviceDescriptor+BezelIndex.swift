import Foundation

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

// MARK: - O(1) lookup tables (Watch)

struct WatchBezelKey: Hashable {
    let series: String
    let size: String
    let material: String
    let color: String
    let band: String
}

struct WatchBezelTables: Sendable {
    let byKey: [WatchBezelKey: URL]

    init(from index: [(parsed: ParsedWatchBezelName, url: URL)]) {
        var out: [WatchBezelKey: URL] = [:]
        for entry in index {
            let key = WatchBezelKey(
                series: entry.parsed.series,
                size: entry.parsed.size,
                material: entry.parsed.material,
                color: entry.parsed.color,
                band: entry.parsed.band
            )
            if out[key] == nil { out[key] = entry.url }
        }
        self.byKey = out
    }
}

private let watchTablesCache = GenerationCache<WatchBezelTables> {
    [WatchBezelTables(from: watchIndexCache.current())]
}

extension ParsedWatchBezelName {
    static var tables: WatchBezelTables {
        watchTablesCache.current().first ?? WatchBezelTables(from: [])
    }
}

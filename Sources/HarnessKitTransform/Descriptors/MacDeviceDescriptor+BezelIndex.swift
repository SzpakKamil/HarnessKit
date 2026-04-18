import Foundation

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

// MARK: - O(1) lookup tables (Mac)

struct MacBezelKey: Hashable {
    let device: String
    let size: String
    let model: String
    let color: String
    let osMajor: String
    let wallpaper: String
    let appearance: String
}

struct MacBezelTables: Sendable {
    let byKey: [MacBezelKey: URL]

    init(from index: [(parsed: ParsedBezelName, url: URL)]) {
        var out: [MacBezelKey: URL] = [:]
        for entry in index {
            for model in entry.parsed.models {
                let key = MacBezelKey(
                    device: entry.parsed.device,
                    size: entry.parsed.size,
                    model: model,
                    color: entry.parsed.color,
                    osMajor: entry.parsed.osMajor,
                    wallpaper: entry.parsed.wallpaper,
                    appearance: entry.parsed.appearance
                )
                if out[key] == nil { out[key] = entry.url }
            }
        }
        self.byKey = out
    }
}

private let macTablesCache = GenerationCache<MacBezelTables> {
    [MacBezelTables(from: macIndexCache.current())]
}

extension ParsedBezelName {
    static var tables: MacBezelTables {
        macTablesCache.current().first ?? MacBezelTables(from: [])
    }
}

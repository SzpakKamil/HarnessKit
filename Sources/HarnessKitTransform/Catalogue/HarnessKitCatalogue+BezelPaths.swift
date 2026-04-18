import Foundation
import HarnessKitScreenshots

extension HarnessKitCatalogue {

    /// Every manifest path under `bezels/mac/` whose parsed `(size, color)` matches
    /// this `VersionedBezel`. The screenshot-time selector later filters by
    /// `(os, wallpaper, appearance, model)` — we prefetch the union.
    func macBezelRelativePaths(for bezel: VersionedBezel, in manifest: Manifest) -> Set<String> {
        // Extract size from deviceID. Handles both M-series ("MacbookPro14M4") and
        // A-series ("MacbookNeo13A18Pro").
        let size: String
        if let mRange = bezel.deviceID.firstMatch(of: BezelIDRegex.macMProcessorWithSize) {
            size = String(bezel.deviceID[mRange].prefix { $0.isNumber })
        } else if let aRange = bezel.deviceID.firstMatch(of: BezelIDRegex.macAProcessorWithSize) {
            size = String(bezel.deviceID[aRange].prefix { $0.isNumber })
        } else {
            return []
        }

        var result: Set<String> = []
        let bucket = manifest.filesByPrefix[RemotePath.macBezelPrefix] ?? []
        let prefixLen = RemotePath.macBezelPrefix.count
        for path in bucket {
            // Zero-copy slice into the bucket key — `parseKeyedFilename(Substring)`
            // avoids allocating a fresh String per iteration.
            let name = path.dropFirst(prefixLen)
            let fields = parseKeyedFilename(name)
            if fields["size"] == size && fields["color"] == bezel.color {
                result.insert(path)
            }
        }
        return result
    }

    /// Every manifest path under `bezels/pad/` matching the (device family, processor, color)
    /// derived from the `VersionedBezel` deviceID (e.g. `"iPadAir11M4"` → family `"iPadAir11"`, processor `"M4"`).
    func padBezelRelativePaths(for bezel: VersionedBezel, in manifest: Manifest) -> Set<String> {
        let (family, processor) = parsePadDeviceID(bezel.deviceID)
        var result: Set<String> = []
        let bucket = manifest.filesByPrefix[RemotePath.padBezelPrefix] ?? []
        let prefixLen = RemotePath.padBezelPrefix.count
        for path in bucket {
            let name = path.dropFirst(prefixLen)
            let fields = parseKeyedFilename(name)
            guard fields["device"] == family && fields["color"] == bezel.color else { continue }
            if let processor {
                let procs = Set((fields["processors"] ?? "").split(separator: "+").map(String.init))
                guard procs.contains(processor) else { continue }
            }
            result.insert(path)
        }
        return result
    }

    /// Splits `"iPadAir11M4"` → `("iPadAir11", "M4")`, `"iPad9thGen"` → `("iPad9thGen", nil)`.
    func parsePadDeviceID(_ id: String) -> (family: String, processor: String?) {
        guard let range = id.firstMatch(of: BezelIDRegex.processorSuffix) else {
            return (id, nil)
        }
        return (String(id[id.startIndex..<range.lowerBound]), String(id[range]))
    }

    /// Every manifest path under `bezels/watch/` matching the (series, size, material, color, band)
    /// derived from the `VersionedBezel` deviceID.
    func watchBezelRelativePaths(for bezel: VersionedBezel, in manifest: Manifest) -> Set<String> {
        let stripped = bezel.deviceID.hasPrefix("AppleWatch")
            ? String(bezel.deviceID.dropFirst("AppleWatch".count))
            : bezel.deviceID
        guard let mmRange = stripped.range(of: "mm") else { return [] }
        let beforeMM = String(stripped[stripped.startIndex..<mmRange.lowerBound])
        let material = String(stripped[mmRange.upperBound...])
        // All Apple Watch sizes are exactly 2 digits (41, 42, 44, 45, 46, 49).
        let size = String(beforeMM.suffix(2))
        let series = String(beforeMM.dropLast(2))

        var result: Set<String> = []
        let bucket = manifest.filesByPrefix[RemotePath.watchBezelPrefix] ?? []
        let prefixLen = RemotePath.watchBezelPrefix.count
        for path in bucket {
            let name = path.dropFirst(prefixLen)
            let fields = parseKeyedFilename(name)
            if fields["series"]   == series
                && fields["size"]     == size
                && fields["material"] == material
                && fields["color"]    == bezel.color
                && fields["band"]     == bezel.band {
                result.insert(path)
            }
        }
        return result
    }

    /// Every manifest path under `bezels/tv/` matching the device and color.
    /// Handles both simple (`device*AppleTVFrame^color*Default.png`) and generation-set
    /// (`device*AppleTVFrameBox^gens*HD+4K1+4K2+4K3^color*Default.png`) filenames.
    func tvBezelRelativePaths(for bezel: VersionedBezel, in manifest: Manifest) -> Set<String> {
        var result: Set<String> = []
        let bucket = manifest.filesByPrefix[RemotePath.tvBezelPrefix] ?? []
        let prefixLen = RemotePath.tvBezelPrefix.count
        for path in bucket {
            let name = path.dropFirst(prefixLen)
            let fields = parseKeyedFilename(name)
            if fields["device"] == bezel.deviceID && fields["color"] == bezel.color {
                result.insert(path)
            }
        }
        return result
    }
}

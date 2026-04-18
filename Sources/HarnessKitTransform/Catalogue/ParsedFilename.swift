import Foundation

/// Parses a keyed filename in `key*value^key*value.ext` format into a dictionary.
///
/// Used for bezel filenames like `device*iPhone16^color*Black.png` or
/// `device*MacbookPro^size*14^models*M2+M3^color*Silver^os*26^wallpaper*Default^appearance*Light.png`.
///
/// The file extension is stripped before parsing. Each `^`-separated component
/// is split on the first `*` to produce a key-value pair.
func parseKeyedFilename(_ name: String) -> [String: String] {
    parseKeyedFilename(Substring(name))
}

/// Substring-accepting overload. Lets callers iterating over a `Dictionary.Keys`
/// collection of full paths pass `path[prefixEnd...]` directly instead of
/// materializing a fresh `String` per path (saves one alloc per bezel-match
/// iteration; ~200–500 iterations per prefetch).
func parseKeyedFilename(_ name: Substring) -> [String: String] {
    // Strip `.png` / `.jpg` / any trailing extension by finding the last `.`
    // within the substring's own range — avoids NSString bridge + its copy.
    let base: Substring
    if let dot = name.lastIndex(of: ".") {
        base = name[..<dot]
    } else {
        base = name
    }
    var fields: [String: String] = [:]
    for component in base.split(separator: "^") {
        let pair = component.split(separator: "*", maxSplits: 1)
        if pair.count == 2 { fields[String(pair[0])] = String(pair[1]) }
    }
    return fields
}

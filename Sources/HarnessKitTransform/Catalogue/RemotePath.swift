//
//  RemotePath.swift
//  HarnessKitTransform
//

import Foundation

/// Relative-path constants + URL encoding for the R2 asset layout.
///
/// The Mac bezel filenames use `*`, `^`, and `+` as delimiters (Screenshot-style
/// `key*value^key*value.png`). All three are unsafe in URL paths — we percent-encode
/// per path component but leave `/` separators intact.
enum RemotePath {

    static let manifest = "manifest.json"

    // Platform prefixes — must match the paths used by `upload_to_r2.sh`.
    static let macBezelPrefix    = "bezels/mac/"
    static let phoneBezelPrefix  = "bezels/phone/"
    static let padBezelPrefix    = "bezels/pad/"
    static let watchBezelPrefix  = "bezels/watch/"
    static let tvBezelPrefix     = "bezels/tv/"
    static let visionBezelPrefix = "bezels/vision/"

    static let cataloguePrefix   = "catalogue/"

    /// Appends `relativePath` to `baseURL`, percent-encoding each path component
    /// so characters like `*`, `^`, `+` become `%2A`, `%5E`, `%2B`.
    static func url(base: URL, relativePath: String) -> URL? {
        let components = relativePath.split(separator: "/", omittingEmptySubsequences: false)
        let encodedParts: [String] = components.compactMap { part in
            part.addingPercentEncoding(withAllowedCharacters: .urlPathAllowedExcludingDelimiters)
        }
        guard encodedParts.count == components.count else { return nil }
        let joined = encodedParts.joined(separator: "/")
        return URL(string: joined, relativeTo: base)?.absoluteURL
    }
}

private extension CharacterSet {
    /// `urlPathAllowed` minus the Screenshot-style delimiters so they get escaped.
    static let urlPathAllowedExcludingDelimiters: CharacterSet = {
        var set = CharacterSet.urlPathAllowed
        set.remove(charactersIn: "*^+")
        return set
    }()
}

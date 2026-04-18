import Foundation

/// The remote manifest schema version this client understands. Manifests with a
/// higher `schemaVersion` are ignored (the client keeps using its previous state).
let kHarnessKitManifestSchemaVersion = 1

/// One file entry in the manifest.
struct ManifestFile: Codable, Equatable {
    /// Hex-encoded SHA-256 of the file bytes.
    let sha256: String
    /// File size in bytes.
    let size: Int
}

/// Top-level manifest as served at `/manifest.json` on the R2 origin.
/// See `~/.claude/plans/shimmering-rolling-quasar.md` for the design notes.
///
/// ## Device Imagery Notice
/// The bezel PNG files referenced in this manifest depict Apple hardware and are
/// the intellectual property of Apple Inc. They are distributed in accordance with
/// Apple's App Store Marketing Guidelines (https://developer.apple.com/app-store/marketing/guidelines/)
/// and may only be used to frame screenshots of your own application for App Store promotion.
/// Apple, iPhone, iPad, Apple Watch, Apple TV, and Mac are trademarks of Apple Inc.
struct Manifest: Codable, Equatable {
    let schemaVersion: Int
    let catalogueVersion: String
    let generatedAt: String
    /// Attribution notice embedded in every published manifest.
    /// Device images are property of Apple Inc. and are used in accordance with
    /// Apple's App Store Marketing Guidelines for the sole purpose of app promotion.
    let notice: String?
    /// Map of R2-relative path (e.g. `"bezels/mac/device*…*Dark.png"`) → sha256 + size.
    let files: [String: ManifestFile]
    /// Prefix-grouped index over `files.keys`, populated once at init/decode.
    /// Keys are `""` (all paths), the top-level segment (e.g. `"bezels/"`),
    /// and the two-segment prefix (e.g. `"bezels/mac/"`). Values are
    /// **`Set<String>`** of the paths that match — callers that need
    /// `ManifestFile` entries look them up via `manifest.files[path]`.
    ///
    /// Previously stored full `[String: ManifestFile]` sub-dicts per bucket,
    /// which duplicated the ManifestFile value (sha + size) in every
    /// bucket that contained a path. With 3 buckets per path on average
    /// that was 3× the file-entry footprint on top of the primary `files`
    /// dict. Keys-only storage drops the duplication; `files` remains
    /// the single source of truth for values.
    let filesByPrefix: [String: Set<String>]

    private enum CodingKeys: String, CodingKey {
        case schemaVersion, catalogueVersion, generatedAt, notice, files
    }

    init(schemaVersion: Int,
         catalogueVersion: String,
         generatedAt: String,
         notice: String?,
         files: [String: ManifestFile]) {
        self.schemaVersion = schemaVersion
        self.catalogueVersion = catalogueVersion
        self.generatedAt = generatedAt
        self.notice = notice
        self.files = files
        self.filesByPrefix = Self.groupByPrefix(files)
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        let schemaVersion = try c.decode(Int.self, forKey: .schemaVersion)
        let catalogueVersion = try c.decode(String.self, forKey: .catalogueVersion)
        let generatedAt = try c.decode(String.self, forKey: .generatedAt)
        let notice = try c.decodeIfPresent(String.self, forKey: .notice)
        let files = try c.decode([String: ManifestFile].self, forKey: .files)
        self.init(schemaVersion: schemaVersion,
                  catalogueVersion: catalogueVersion,
                  generatedAt: generatedAt,
                  notice: notice,
                  files: files)
    }

    /// Equality ignores `filesByPrefix` — it's a deterministic function of `files`,
    /// so comparing it would just duplicate work.
    static func == (lhs: Manifest, rhs: Manifest) -> Bool {
        lhs.schemaVersion == rhs.schemaVersion
            && lhs.catalogueVersion == rhs.catalogueVersion
            && lhs.generatedAt == rhs.generatedAt
            && lhs.notice == rhs.notice
            && lhs.files == rhs.files
    }

    /// Buckets every path into prefix-keyed `Set<String>`s. For each path with
    /// at least one `/`, the path is added to:
    ///   * the two-segment prefix bucket (e.g. `"bezels/mac/"`) when the path
    ///     has a second `/` (otherwise this branch is skipped);
    ///   * the one-segment top-level prefix bucket (e.g. `"bezels/"` or `"catalogue/"`);
    ///   * the `""` sentinel bucket (matches every path).
    /// Paths with no `/` are not bucketed (no caller queries for them).
    private static func groupByPrefix(_ files: [String: ManifestFile]) -> [String: Set<String>] {
        var buckets: [String: Set<String>] = [:]
        for path in files.keys {
            guard let firstSlash = path.firstIndex(of: "/") else { continue }
            let afterFirst = path.index(after: firstSlash)
            if let secondSlash = path[afterFirst...].firstIndex(of: "/") {
                let twoSegmentPrefix = String(path[..<path.index(after: secondSlash)])
                buckets[twoSegmentPrefix, default: []].insert(path)
            }
            let topPrefix = String(path[...firstSlash])
            buckets[topPrefix, default: []].insert(path)
            buckets["", default: []].insert(path)
        }
        return buckets
    }
}

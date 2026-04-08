//
//  Manifest.swift
//  HarnessKitTransform
//

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
}

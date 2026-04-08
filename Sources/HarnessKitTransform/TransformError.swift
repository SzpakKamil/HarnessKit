//
//  TransformError.swift
//  HarnessKitTransform
//

import Foundation

public enum TransformError: LocalizedError {
    case bezelNotFound(screenshotID: String)
    case bezelImageMissing(bezelID: String)
    case outputDirectoryUnavailable(URL, Error)
    case imageSaveFailed(URL, Error)

    /// Device descriptor not found in a catalogue JSON.
    case descriptorNotFound(id: String, catalogue: String)
    /// Bezel PNG file not found in cache or bundle.
    case bezelFileNotFound(id: String, color: String)
    /// Device ID could not be parsed (e.g. missing processor suffix for iPad).
    case cannotParseDeviceID(id: String)
    /// One or more expected paths were not found in the R2 manifest.
    /// Indicates the manifest was generated without including these files.
    case notInManifest(paths: [String])
    /// No manifest has been loaded — `refresh()` hasn't been called or failed.
    case manifestNotLoaded

    public var errorDescription: String? {
        switch self {
        case .bezelNotFound(let id):
            return "No bezel found for screenshot '\(id)'"
        case .bezelImageMissing(let id):
            return "Bezel image missing for '\(id)'"
        case .outputDirectoryUnavailable(let url, let underlying):
            return "Cannot create output directory '\(url.path)': \(underlying.localizedDescription)"
        case .imageSaveFailed(let url, let underlying):
            return "Failed to save image to '\(url.path)': \(underlying.localizedDescription)"
        case .descriptorNotFound(let id, let catalogue):
            return "Device descriptor '\(id)' not found in \(catalogue)"
        case .bezelFileNotFound(let id, let color):
            return "Bezel image for '\(id)' color '\(color)' not found in cache or bundle"
        case .cannotParseDeviceID(let id):
            return "Cannot parse device ID '\(id)'"
        case .notInManifest(let paths):
            let list = paths.prefix(10).joined(separator: "\n  ")
            let suffix = paths.count > 10 ? "\n  … and \(paths.count - 10) more" : ""
            return "Missing from manifest (\(paths.count) file\(paths.count == 1 ? "" : "s")):\n  \(list)\(suffix)"
        case .manifestNotLoaded:
            return "No manifest loaded — call HarnessKitCatalogue.shared.refresh() first"
        }
    }
}

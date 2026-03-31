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
        }
    }
}

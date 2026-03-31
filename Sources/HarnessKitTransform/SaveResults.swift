//
//  SaveResults.swift
//  HarnessKitTransform
//

import Foundation
import AppKit

/// Saves `image` as a PNG file named `name` inside `directory`.
/// The `.png` extension is appended automatically if not already present.
/// Throws `TransformError` on failure.
public nonisolated func saveResults(image: NSImage, name: String, to directory: URL) throws {
    let fileManager = FileManager.default

    do {
        try fileManager.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
    } catch {
        throw TransformError.outputDirectoryUnavailable(directory, error)
    }

    let fileName = name.hasSuffix(".png") ? name : name + ".png"
    let fileURL = directory.appendingPathComponent(fileName)

    guard
        let tiffData = image.tiffRepresentation,
        let bitmap = NSBitmapImageRep(data: tiffData),
        let pngData = bitmap.representation(using: .png, properties: [:])
    else {
        throw TransformError.imageSaveFailed(fileURL, NSError(
            domain: "HarnessKitTransform",
            code: 1,
            userInfo: [NSLocalizedDescriptionKey: "Image could not be converted to PNG"]
        ))
    }

    do {
        try pngData.write(to: fileURL)
    } catch {
        throw TransformError.imageSaveFailed(fileURL, error)
    }
}

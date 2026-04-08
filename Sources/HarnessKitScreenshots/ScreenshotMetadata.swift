//
//  ScreenshotMetadata.swift
//  HarnessKitScreenshots
//

import Foundation
import ImageIO

/// Reads and writes `Screenshot` metadata embedded in PNG files.
///
/// Uses the PNG tEXt `Description` field under `kCGImagePropertyPNGDictionary`
/// to store a JSON-encoded `Screenshot`. Compatible with all Apple platforms via ImageIO.
public enum ScreenshotMetadata {

    private static let metadataKey = kCGImagePropertyPNGDescription as String

    // MARK: - Encode / Decode

    /// Returns PNG property dictionary containing the JSON-encoded screenshot.
    public static func pngProperties(for screenshot: Screenshot) -> [String: Any] {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        guard let data = try? encoder.encode(screenshot),
              let json = String(data: data, encoding: .utf8) else { return [:] }
        return [
            kCGImagePropertyPNGDictionary as String: [metadataKey: json]
        ]
    }

    /// Decodes a `Screenshot` from a PNG properties dictionary (as returned by `CGImageSourceCopyPropertiesAtIndex`).
    public static func screenshot(from properties: [String: Any]) -> Screenshot? {
        guard let pngDict = properties[kCGImagePropertyPNGDictionary as String] as? [String: Any],
              let json = pngDict[metadataKey] as? String,
              let data = json.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(Screenshot.self, from: data)
    }

    // MARK: - File I/O

    /// Reads `Screenshot` metadata from a PNG file on disk.
    /// Returns `nil` if the file has no embedded metadata or can't be read.
    public static func read(from url: URL) -> Screenshot? {
        guard let source = CGImageSourceCreateWithURL(url as CFURL, nil) else { return nil }
        guard let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [String: Any] else { return nil }
        return screenshot(from: properties)
    }

    /// Writes a `CGImage` as a PNG file with embedded `Screenshot` metadata.
    public static func write(cgImage: CGImage, screenshot: Screenshot, to url: URL) throws {
        guard let destination = CGImageDestinationCreateWithURL(url as CFURL, "public.png" as CFString, 1, nil) else {
            throw CocoaError(.fileWriteUnknown)
        }

        let properties = pngProperties(for: screenshot) as CFDictionary
        CGImageDestinationAddImage(destination, cgImage, properties)

        guard CGImageDestinationFinalize(destination) else {
            throw CocoaError(.fileWriteUnknown)
        }
    }
}

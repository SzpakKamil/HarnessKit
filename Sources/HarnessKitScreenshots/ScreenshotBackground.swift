//
//  ScreenshotBackground.swift
//  HarnessKitScreenshots
//

import Foundation

public enum ScreenshotBackground: Hashable, Sendable {
    /// Solid color fill from a hex string (e.g. "FF0000").
    case solid(hex: String)
    /// Linear gradient between two hex colors at a given angle in degrees.
    /// 0° = bottom→top, 90° = left→right, 180° = top→bottom, 270° = right→left.
    case gradient(startHex: String, endHex: String, angle: Double)
    /// Background image loaded from a file.
    /// - `name`: Filename (e.g. "mountains.png").
    /// - `directory`: Full path to the directory containing the image.
    /// - `scale`: Scale factor applied on top of aspect-fill (1.0 = fill, >1 = zoom in). Default 1.0.
    /// - `offsetX`: Horizontal offset as fraction of canvas width (0 = centered). Default 0.
    /// - `offsetY`: Vertical offset as fraction of canvas height (0 = centered). Default 0.
    case image(name: String, directory: String? = nil, scale: Double = 1.0, offsetX: Double = 0, offsetY: Double = 0)
}

// MARK: - Codable

extension ScreenshotBackground: Codable {

    private enum CodingKeys: String, CodingKey {
        case solid, gradient, image
    }

    private struct SolidPayload: Codable {
        let hex: String
    }

    private struct GradientPayload: Codable {
        let startHex: String
        let endHex: String
        let angle: Double
    }

    private struct ImagePayload: Codable {
        let name: String
        var directory: String?
        var scale: Double?
        var offsetX: Double?
        var offsetY: Double?
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let payload = try? container.decode(SolidPayload.self, forKey: .solid) {
            self = .solid(hex: payload.hex)
        } else if let payload = try? container.decode(GradientPayload.self, forKey: .gradient) {
            self = .gradient(startHex: payload.startHex, endHex: payload.endHex, angle: payload.angle)
        } else if let payload = try? container.decode(ImagePayload.self, forKey: .image) {
            self = .image(
                name: payload.name,
                directory: payload.directory,
                scale: payload.scale ?? 1.0,
                offsetX: payload.offsetX ?? 0,
                offsetY: payload.offsetY ?? 0
            )
        } else {
            throw DecodingError.dataCorrupted(.init(codingPath: decoder.codingPath, debugDescription: "Unknown ScreenshotBackground case"))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .solid(let hex):
            try container.encode(SolidPayload(hex: hex), forKey: .solid)
        case .gradient(let startHex, let endHex, let angle):
            try container.encode(GradientPayload(startHex: startHex, endHex: endHex, angle: angle), forKey: .gradient)
        case .image(let name, let directory, let scale, let offsetX, let offsetY):
            var payload = ImagePayload(name: name)
            payload.directory = directory
            if scale != 1.0 { payload.scale = scale }
            if offsetX != 0 { payload.offsetX = offsetX }
            if offsetY != 0 { payload.offsetY = offsetY }
            try container.encode(payload, forKey: .image)
        }
    }
}

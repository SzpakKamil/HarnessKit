//
//  BezelDescriptor.swift
//  HarnessKitTransform
//

import Foundation
import AppKit
import HarnessKitScreenshots

public protocol BezelDescriptor:
    CaseIterable,
    Identifiable,
    Equatable,
    Hashable,
    Sendable,
    Codable
where ID == String {
    var shortID: String { get }
    var prettyName: String { get }
    var model: String { get }
    var runDestination: String { get }
    var scale: CGFloat { get }
    var verticalOffset: CGFloat { get }
    static func bezel(for id: String) throws -> Self
}

public extension BezelDescriptor {

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let id = try container.decode(String.self)
        self = try Self.bezel(for: id)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(id)
    }

    static func bezel(for id: String) throws -> Self {
        if let match = Self.allCases.first(where: { $0.id == id }) {
            return match
        }
        throw NSError(
            domain: "BezelDescriptor",
            code: -1,
            userInfo: [NSLocalizedDescriptionKey: "Bezel with id '\(id)' not found"]
        )
    }

    static func groupedByStyle() -> [String: [Self]] {
        let grouped = Dictionary(grouping: allCases) { $0.model }
        return grouped.mapValues {
            $0.sorted { $0.id < $1.id }
        }
    }

    func borderImage(
        os: TargetOS? = nil,
        appearance: ScreenshotAppearance? = nil
    ) throws -> NSImage {
        let bundle = Bundle.module
        let resourceExtension = "png"
        let resourceName: String

        if Self.self == MacBezel.self {
            guard let os, let appearance else {
                throw NSError(
                    domain: "BezelDescriptor",
                    code: -2,
                    userInfo: [
                        NSLocalizedDescriptionKey:
                            "Operating System and Appearance must be provided for macOS bezels"
                    ]
                )
            }
            resourceName = "\(id)\(os.id)\(appearance.rawValue)"
        } else {
            resourceName = id
        }

        guard
            let url = bundle.url(forResource: resourceName, withExtension: resourceExtension),
            let image = NSImage(contentsOf: url)
        else {
            throw NSError(
                domain: "BezelDescriptor",
                code: -3,
                userInfo: [
                    NSLocalizedDescriptionKey:
                        "Border '\(resourceName).\(resourceExtension)' not found in bundle"
                ]
            )
        }

        return image
    }

    func maskImage() throws -> NSImage {
        let bundle = Bundle.module
        let maskName = "\(shortID)Mask"
        let maskExtension = "png"

        guard
            let url = bundle.url(forResource: maskName, withExtension: maskExtension),
            let image = NSImage(contentsOf: url)
        else {
            throw NSError(
                domain: "BezelDescriptor",
                code: -3,
                userInfo: [
                    NSLocalizedDescriptionKey:
                        "Mask '\(maskName).\(maskExtension)' not found in bundle"
                ]
            )
        }

        return image
    }
}

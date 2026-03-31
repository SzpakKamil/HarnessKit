//
//  ExportPath.swift
//  HarnessKitScreenshots
//

import Foundation

#if os(macOS)
public struct ExportPath: Identifiable, Codable, Equatable, Hashable {
    public var id: String
    public var destination: String

    public var name: String {
        id
    }

    public init(id: String, destination: String) {
        self.id = id
        self.destination = destination
    }

    private static let folderName = "Packages Photos Creator"
    private static let fileName = "export_paths.json"

    private static var fileURL: URL {
        get throws {
            let appSupport = FileManager.default.urls(
                for: .applicationSupportDirectory,
                in: .userDomainMask
            ).first!

            let folderURL = appSupport.appendingPathComponent(folderName, isDirectory: true)

            if !FileManager.default.fileExists(atPath: folderURL.path) {
                try FileManager.default.createDirectory(
                    at: folderURL,
                    withIntermediateDirectories: true
                )
            }

            return folderURL.appendingPathComponent(fileName)
        }
    }

    public static func save(_ paths: [ExportPath]) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted]
        let data = try encoder.encode(paths)
        try data.write(to: try fileURL, options: [.atomic])
    }

    public static func load() throws -> [ExportPath] {
        let url = try fileURL
        guard FileManager.default.fileExists(atPath: url.path) else {
            return []
        }
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode([ExportPath].self, from: data)
    }
}
#endif

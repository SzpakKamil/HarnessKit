//
//  MacDeviceDescriptor+Catalogue.swift
//  HarnessKitTransform
//
//  Static Mac device catalogue loader with generation-keyed caching.
//

import Foundation

// MARK: - JSON catalogue

private struct MacDeviceCatalogue: Codable {
    let devices: [MacDeviceDescriptor]
}

private let macCache = GenerationCache<MacDeviceDescriptor> {
    guard
        let data = CatalogueStore.shared.json(forCatalogueName: "mac_devices"),
        let catalogue = try? JSONDecoder().decode(MacDeviceCatalogue.self, from: data)
    else { return [] }
    return catalogue.devices
}

// MARK: - Static loader

public extension MacDeviceDescriptor {

    /// All descriptors loaded from `mac_devices.json` — remote cache if present,
    /// bundled baseline otherwise. Cached per `CatalogueStore` generation.
    static var all: [MacDeviceDescriptor] {
        macCache.current()
    }

    /// Finds a descriptor by its `id` field.
    /// - Throws: `TransformError.descriptorNotFound` if no matching descriptor is found.
    static func descriptor(for id: String) throws -> MacDeviceDescriptor {
        guard let match = all.first(where: { $0.id == id }) else {
            throw TransformError.descriptorNotFound(id: id, catalogue: "mac_devices")
        }
        return match
    }
}

//
//  WatchDeviceDescriptor+Catalogue.swift
//  HarnessKitTransform
//
//  Static Watch device catalogue loader with generation-keyed caching.
//

import Foundation

// MARK: - JSON catalogue

private struct WatchDeviceCatalogue: Codable {
    let devices: [WatchDeviceDescriptor]
}

private let watchCache = GenerationCache<WatchDeviceDescriptor> {
    guard
        let data = CatalogueStore.shared.json(forCatalogueName: "watch_devices"),
        let catalogue = try? JSONDecoder().decode(WatchDeviceCatalogue.self, from: data)
    else { return [] }
    return catalogue.devices
}

// MARK: - Static loader

public extension WatchDeviceDescriptor {

    /// All descriptors loaded from `watch_devices.json` — remote cache if present,
    /// bundled baseline otherwise. Cached per `CatalogueStore` generation.
    static var all: [WatchDeviceDescriptor] {
        watchCache.current()
    }

    /// Finds a descriptor by its `id` field.
    /// - Throws: `TransformError.descriptorNotFound` if no matching descriptor is found.
    static func descriptor(for id: String) throws -> WatchDeviceDescriptor {
        guard let match = all.first(where: { $0.id == id }) else {
            throw TransformError.descriptorNotFound(id: id, catalogue: "watch_devices")
        }
        return match
    }
}

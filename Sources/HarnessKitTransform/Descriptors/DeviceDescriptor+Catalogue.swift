import Foundation

// MARK: - JSON catalogue

private struct DeviceCatalogue: Codable {
    let devices: [DeviceDescriptor]
}

// MARK: - Static loaders

private let phoneCache  = GenerationCache { loadDevices("phone_devices") }
private let padCache    = GenerationCache { loadDevices("pad_devices") }
private let tvCache     = GenerationCache { loadDevices("tv_devices") }
private let visionCache = GenerationCache { loadDevices("vision_devices") }

private func loadDevices(_ filename: String) -> [DeviceDescriptor] {
    guard
        let data = CatalogueStore.shared.json(forCatalogueName: filename),
        let catalogue = try? JSONDecoder().decode(DeviceCatalogue.self, from: data)
    else { return [] }
    return catalogue.devices
}

public extension DeviceDescriptor {

    /// All phone (iPhone) descriptors loaded from `phone_devices.json`.
    static var allPhone:  [DeviceDescriptor] { phoneCache.current() }
    /// All iPad descriptors loaded from `pad_devices.json`.
    static var allPad:    [DeviceDescriptor] { padCache.current() }
    /// All Apple TV descriptors loaded from `tv_devices.json`.
    static var allTV:     [DeviceDescriptor] { tvCache.current() }
    /// All Apple Vision Pro descriptors loaded from `vision_devices.json`.
    static var allVision: [DeviceDescriptor] { visionCache.current() }

    /// Finds a descriptor by `id` in the given catalogue.
    /// - Throws: `TransformError.descriptorNotFound` if no matching descriptor is found.
    static func descriptor(for id: String, in catalogue: [DeviceDescriptor]) throws -> DeviceDescriptor {
        guard let match = catalogue.first(where: { $0.id == id }) else {
            throw TransformError.descriptorNotFound(id: id, catalogue: "device_descriptors")
        }
        return match
    }
}

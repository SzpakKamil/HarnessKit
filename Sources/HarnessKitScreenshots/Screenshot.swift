//
//  Screenshot.swift
//  HarnessKitScreenshots
//

import Foundation

public struct Screenshot: Identifiable, Hashable, Equatable, Sendable {
    public let id: String
    public let appearance: ScreenshotAppearance
    public let os: TargetOS
    public let orientation: ScreenOrientation?
    public let crop: CropRect
    public let background: ScreenshotBackground?
    public let shadows: [ScreenshotShadow]
    public let addBezel: Bool
    /// Target OS version string (e.g. "17.0", "18.2", "26.0").
    /// Set automatically by the testing infrastructure from the real running OS.
    /// Not exposed in the public init — use `captureScreenshot` to capture with the correct version.
    public let osVersion: String?

    /// Backward-compat: extract solid hex color if background is `.solid`.
    public var backgroundHex: String? {
        if case .solid(let hex) = background { return hex }
        return nil
    }

    public init(
        id: String,
        appearance: ScreenshotAppearance,
        os: TargetOS = .currentOS,
        orientation: ScreenOrientation? = nil,
        crop: CropRect = .init(x: 0, y: 0, width: 1, height: 1),
        backgroundHex: String? = nil,
        shadows: [ScreenshotShadow] = [],
        addBezel: Bool = true
    ) {
        self.id = id
        self.appearance = appearance
        self.os = os
        self.orientation = orientation
        self.crop = crop
        self.background = backgroundHex.map { .solid(hex: $0) }
        self.shadows = shadows
        self.addBezel = addBezel
        self.osVersion = nil
    }

    public init(
        id: String,
        appearance: ScreenshotAppearance,
        os: TargetOS = .currentOS,
        orientation: ScreenOrientation? = nil,
        crop: CropRect = .init(x: 0, y: 0, width: 1, height: 1),
        background: ScreenshotBackground?,
        shadows: [ScreenshotShadow] = [],
        addBezel: Bool = true
    ) {
        self.id = id
        self.appearance = appearance
        self.os = os
        self.orientation = orientation
        self.crop = crop
        self.background = background
        self.shadows = shadows
        self.addBezel = addBezel
        self.osVersion = nil
    }

    // Infrastructure-only init — also used by fromScreenshotName(_:)
    private init(
        id: String,
        appearance: ScreenshotAppearance,
        os: TargetOS,
        orientation: ScreenOrientation?,
        crop: CropRect,
        background: ScreenshotBackground?,
        shadows: [ScreenshotShadow],
        addBezel: Bool,
        osVersion: String?
    ) {
        self.id = id
        self.appearance = appearance
        self.os = os
        self.orientation = orientation
        self.crop = crop
        self.background = background
        self.shadows = shadows
        self.addBezel = addBezel
        self.osVersion = osVersion
    }

    /// Returns a copy of this screenshot with `osVersion` set to `version`.
    /// Called by `captureScreenshot` to attach the real running OS major version.
    public func withOSVersion(_ version: String) -> Screenshot {
        Screenshot(
            id: id,
            appearance: appearance,
            os: os,
            orientation: orientation,
            crop: crop,
            background: background,
            shadows: shadows,
            addBezel: addBezel,
            osVersion: version
        )
    }

    /// Serializes all screenshot metadata into a single stable filename string.
    /// Format:
    /// id*value^os*value^orientation*value^appearance*value^crop*x,y,w,h^backgroundHex*value[^osVersion*value][^addBezel*false].png
    public func screenshotName() -> String {
        let cropPart = "\(crop.x),\(crop.y),\(crop.width),\(crop.height)"
        let backgroundPart: String
        switch background {
        case .solid(let hex):
            backgroundPart = "solid:\(hex)"
        case .gradient(let s, let e, let a):
            backgroundPart = "gradient:\(s),\(e),\(a)"
        case .image(let name, let directory, let scale, let offsetX, let offsetY):
            var parts = "image:\(name)"
            if let directory { parts += ",dir:\(directory)" }
            if scale != 1.0 { parts += ",s:\(scale)" }
            if offsetX != 0 { parts += ",ox:\(offsetX)" }
            if offsetY != 0 { parts += ",oy:\(offsetY)" }
            backgroundPart = parts
        case .none:
            backgroundPart = "nil"
        }

        var components = [
            "id*\(id)",
            "os*\(os)",
            "orientation*\(orientation?.rawValue ?? "nil")",
            "appearance*\(appearance)",
            "crop*\(cropPart)",
            "background*\(backgroundPart)"
        ]

        if let osVersion {
            components.append("osVersion*\(osVersion)")
        }

        if !addBezel {
            components.append("addBezel*false")
        }

        return components.joined(separator: "^") + ".png"
    }

    public func prettyName() -> String {
        var name = "\(id)-\(os)"

        if let osVersion {
            name += "_\(osVersion)"
        }

        if appearance == .dark {
            name += "~\(appearance)"
        }

        return name
    }

    /// Reconstructs a Screenshot from a screenshot name string.
    /// Returns nil if the format is invalid.
    public static func fromScreenshotName(_ name: String) -> Screenshot? {
        let baseName = (name as NSString).deletingPathExtension
        let components = baseName.split(separator: "^")
        var id: String?
        var os: TargetOS?
        var orientation: ScreenOrientation?
        var appearance: ScreenshotAppearance?
        var crop: CropRect?
        var background: ScreenshotBackground?
        var addBezel: Bool = true
        var osVersion: String?

        for component in components {
            let pair = component.split(separator: "*", maxSplits: 1)
            guard pair.count == 2 else { continue }

            let key = pair[0]
            let value = String(pair[1])

            switch key {
            case "id":
                id = value

            case "os":
                os = TargetOS(rawValue: value)

            case "orientation":
                orientation = value == "nil" ? nil : ScreenOrientation(rawValue: value)

            case "appearance":
                appearance = ScreenshotAppearance(rawValue: value.capitalized)

            case "crop":
                let numbers = value.split(separator: ",").compactMap { Double($0) }
                guard numbers.count == 4 else { return nil }
                crop = CropRect(
                    x: numbers[0],
                    y: numbers[1],
                    width: numbers[2],
                    height: numbers[3]
                )

            case "backgroundHex":
                // Backward compat: old format stored plain hex
                background = value == "nil" ? nil : .solid(hex: value)

            case "background":
                if value == "nil" {
                    background = nil
                } else if value.hasPrefix("solid:") {
                    background = .solid(hex: String(value.dropFirst(6)))
                } else if value.hasPrefix("gradient:") {
                    let parts = value.dropFirst(9).split(separator: ",")
                    if parts.count == 3, let angle = Double(parts[2]) {
                        background = .gradient(startHex: String(parts[0]), endHex: String(parts[1]), angle: angle)
                    }
                } else if value.hasPrefix("image:") {
                    let imgParts = value.dropFirst(6).split(separator: ",", omittingEmptySubsequences: false)
                    let name = String(imgParts[0])
                    var directory: String?
                    var scale = 1.0
                    var offsetX = 0.0
                    var offsetY = 0.0
                    for part in imgParts.dropFirst() {
                        if part.hasPrefix("dir:") { directory = String(part.dropFirst(4)) }
                        else if part.hasPrefix("s:"), let v = Double(part.dropFirst(2)) { scale = v }
                        else if part.hasPrefix("ox:"), let v = Double(part.dropFirst(3)) { offsetX = v }
                        else if part.hasPrefix("oy:"), let v = Double(part.dropFirst(3)) { offsetY = v }
                    }
                    background = .image(name: name, directory: directory, scale: scale, offsetX: offsetX, offsetY: offsetY)
                }

            case "osVersion":
                osVersion = value

            case "addBezel":
                addBezel = (value == "true")

            default:
                continue
            }
        }

        guard
            let finalId = id,
            let finalOs = os,
            let finalAppearance = appearance,
            let finalCrop = crop
        else {
            return nil
        }

        return Screenshot(
            id: finalId,
            appearance: finalAppearance,
            os: finalOs,
            orientation: orientation,
            crop: finalCrop,
            background: background,
            shadows: [],
            addBezel: addBezel,
            osVersion: osVersion
        )
    }
}

// MARK: - Codable (backward-compat: reads old "backgroundHex" key, writes new "background" key)

extension Screenshot: Codable {
    private enum CodingKeys: String, CodingKey {
        case id, appearance, os, orientation, crop, background, backgroundHex, shadows, addBezel, osVersion
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(String.self, forKey: .id)
        appearance = try c.decode(ScreenshotAppearance.self, forKey: .appearance)
        os = try c.decode(TargetOS.self, forKey: .os)
        orientation = try c.decodeIfPresent(ScreenOrientation.self, forKey: .orientation)
        crop = try c.decode(CropRect.self, forKey: .crop)
        addBezel = (try? c.decode(Bool.self, forKey: .addBezel)) ?? true
        osVersion = try c.decodeIfPresent(String.self, forKey: .osVersion)

        // Try new "background" key first, fall back to old "backgroundHex"
        if let bg = try? c.decodeIfPresent(ScreenshotBackground.self, forKey: .background) {
            background = bg
        } else if let hex = try? c.decodeIfPresent(String.self, forKey: .backgroundHex) {
            background = .solid(hex: hex)
        } else {
            background = nil
        }
        shadows = (try? c.decodeIfPresent([ScreenshotShadow].self, forKey: .shadows)) ?? []
    }

    public func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id, forKey: .id)
        try c.encode(appearance, forKey: .appearance)
        try c.encode(os, forKey: .os)
        try c.encodeIfPresent(orientation, forKey: .orientation)
        try c.encode(crop, forKey: .crop)
        try c.encodeIfPresent(background, forKey: .background)
        if !shadows.isEmpty {
            try c.encode(shadows, forKey: .shadows)
        }
        try c.encode(addBezel, forKey: .addBezel)
        try c.encodeIfPresent(osVersion, forKey: .osVersion)
    }
}

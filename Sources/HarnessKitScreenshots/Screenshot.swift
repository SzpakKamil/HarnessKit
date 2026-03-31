//
//  Screenshot.swift
//  HarnessKitScreenshots
//

import Foundation

public struct Screenshot: Identifiable, Codable, Hashable, Equatable, Sendable {
    public let id: String
    public let appearance: ScreenshotAppearance
    public let os: TargetOS
    public let orientation: ScreenOrientation?
    public let crop: CropRect
    public let backgroundHex: String?
    public let addBezel: Bool
    /// Target OS version string (e.g. "17.0", "18.2", "26.0").
    /// Used to select the correct versioned bezel during transformation.
    public let osVersion: String?

    public init(
        id: String,
        appearance: ScreenshotAppearance,
        os: TargetOS = .currentOS,
        orientation: ScreenOrientation? = nil,
        crop: CropRect = .init(x: 0, y: 0, width: 1, height: 1),
        backgroundHex: String? = nil,
        addBezel: Bool = true,
        osVersion: String? = nil
    ) {
        self.id = id
        self.appearance = appearance
        self.os = os
        self.orientation = orientation
        self.crop = crop
        self.backgroundHex = backgroundHex
        self.addBezel = addBezel
        self.osVersion = osVersion
    }

    /// Serializes all screenshot metadata into a single stable filename string.
    /// Format:
    /// id*value^os*value^orientation*value^appearance*value^crop*x,y,w,h^backgroundHex*value[^osVersion*value][^addBezel*false].png
    public func screenshotName() -> String {
        let cropPart = "\(crop.x),\(crop.y),\(crop.width),\(crop.height)"
        let backgroundPart = backgroundHex ?? "nil"

        var components = [
            "id*\(id)",
            "os*\(os)",
            "orientation*\(orientation?.rawValue ?? "nil")",
            "appearance*\(appearance)",
            "crop*\(cropPart)",
            "backgroundHex*\(backgroundPart)"
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
        var backgroundHex: String?
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
                backgroundHex = value == "nil" ? nil : value

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
            backgroundHex: backgroundHex,
            addBezel: addBezel,
            osVersion: osVersion
        )
    }
}

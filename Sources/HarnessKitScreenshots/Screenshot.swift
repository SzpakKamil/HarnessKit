import Foundation

public struct Screenshot: Identifiable, Hashable, Equatable, Sendable {
    public let id: String
    public let appearance: ScreenshotAppearance
    public let os: TargetOS
    public let orientation: ScreenOrientation?
    public let addBezel: Bool
    /// Target OS version string (e.g. "17.0", "18.2", "26.0").
    /// Set automatically by the testing infrastructure from the real running OS.
    /// Not exposed in the public init — use `captureScreenshot` to capture with the correct version.
    public let osVersion: String?

    public init(
        id: String,
        appearance: ScreenshotAppearance,
        os: TargetOS = .currentOS,
        orientation: ScreenOrientation? = nil,
        addBezel: Bool = true
    ) {
        self.id = id
        self.appearance = appearance
        self.os = os
        self.orientation = orientation
        self.addBezel = addBezel
        self.osVersion = nil
    }

    // Infrastructure-only init — also used by fromScreenshotName(_:)
    private init(
        id: String,
        appearance: ScreenshotAppearance,
        os: TargetOS,
        orientation: ScreenOrientation?,
        addBezel: Bool,
        osVersion: String?
    ) {
        self.id = id
        self.appearance = appearance
        self.os = os
        self.orientation = orientation
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
            addBezel: addBezel,
            osVersion: version
        )
    }

    /// Serializes all screenshot metadata into a single stable filename string.
    /// Format:
    /// id*value^os*value^orientation*value^appearance*value[^osVersion*value][^addBezel*false].png
    public func screenshotName() -> String {
        var s = ""
        s.reserveCapacity(128)

        s += "id*\(id)"
        s += "^os*\(os)"
        s += "^orientation*\(orientation?.rawValue ?? "nil")"
        s += "^appearance*\(appearance)"

        if let osVersion {
            s += "^osVersion*\(osVersion)"
        }
        if !addBezel {
            s += "^addBezel*false"
        }
        s += ".png"
        return s
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
            let finalAppearance = appearance
        else {
            return nil
        }

        return Screenshot(
            id: finalId,
            appearance: finalAppearance,
            os: finalOs,
            orientation: orientation,
            addBezel: addBezel,
            osVersion: osVersion
        )
    }
}

// MARK: - Codable

extension Screenshot: Codable {
    private enum CodingKeys: String, CodingKey {
        case id, appearance, os, orientation, addBezel, osVersion
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(String.self, forKey: .id)
        appearance = try c.decode(ScreenshotAppearance.self, forKey: .appearance)
        os = try c.decode(TargetOS.self, forKey: .os)
        orientation = try c.decodeIfPresent(ScreenOrientation.self, forKey: .orientation)
        addBezel = (try? c.decode(Bool.self, forKey: .addBezel)) ?? true
        osVersion = try c.decodeIfPresent(String.self, forKey: .osVersion)
    }

    public func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id, forKey: .id)
        try c.encode(appearance, forKey: .appearance)
        try c.encode(os, forKey: .os)
        try c.encodeIfPresent(orientation, forKey: .orientation)
        try c.encode(addBezel, forKey: .addBezel)
        try c.encodeIfPresent(osVersion, forKey: .osVersion)
    }
}

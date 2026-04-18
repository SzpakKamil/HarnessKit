import Foundation
import CoreGraphics

public enum ScreenshotResolution: Sendable, Equatable, Hashable {
    case full
    case `default`
    case custom(width: Int, height: Int)

    public var size: CGSize {
        switch self {
        case .full:
            CGSize(width: 2089, height: 1440)
        case .default:
            CGSize(width: 603, height: 416)
        case .custom(let w, let h):
            CGSize(width: w, height: h)
        }
    }
}

extension ScreenshotResolution: Codable {
    private enum CodingKeys: String, CodingKey { case custom }
    private struct CustomDims: Codable { let width: Int; let height: Int }

    public init(from decoder: Decoder) throws {
        if let container = try? decoder.singleValueContainer(),
           let str = try? container.decode(String.self) {
            switch str {
            case "full":    self = .full
            case "default": self = .default
            default:        self = .default
            }
            return
        }
        let keyed = try decoder.container(keyedBy: CodingKeys.self)
        let dims = try keyed.decode(CustomDims.self, forKey: .custom)
        self = .custom(width: dims.width, height: dims.height)
    }

    public func encode(to encoder: Encoder) throws {
        switch self {
        case .full:
            var c = encoder.singleValueContainer()
            try c.encode("full")
        case .default:
            var c = encoder.singleValueContainer()
            try c.encode("default")
        case .custom(let w, let h):
            var c = encoder.container(keyedBy: CodingKeys.self)
            try c.encode(CustomDims(width: w, height: h), forKey: .custom)
        }
    }
}

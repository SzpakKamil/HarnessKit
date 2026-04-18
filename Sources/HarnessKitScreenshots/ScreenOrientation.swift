import Foundation
import SwiftUI

public enum ScreenOrientation: String, Identifiable, CaseIterable, Sendable, Codable {
    case portrait = "Portrait"
    case landscape = "Landscape"

    public var id: String { name }

    #if os(iOS)
    public var uiKitValue: UIDeviceOrientation {
        switch self {
        case .portrait:
            return .portrait
        case .landscape:
            return .landscapeLeft
        }
    }
    #endif

    public var name: String {
        rawValue
    }

    public static func orientation(from name: String) -> ScreenOrientation {
        switch name {
        case "portrait":
            return .portrait
        case "landscape":
            return .landscape
        default:
            fatalError("Unknown orientation: \(name)")
        }
    }

    /// Returns the orientation based on the size's aspect ratio.
    /// Width greater than height means landscape.
    public static func orientation(fromSize size: CGSize) -> ScreenOrientation {
        if size.width > size.height {
            return .landscape
        } else {
            return .portrait
        }
    }
}

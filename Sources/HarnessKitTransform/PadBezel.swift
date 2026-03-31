//
//  PadBezel.swift
//  HarnessKitTransform
//

import Foundation

public enum PadBezel: BezelDescriptor {
    // ------- iPad 9th Gen ----------
    case `iPad 9th Gen Silver`
    // ------- iPad mini A17 Pro ----------
    case `iPad mini A17 Pro Starlight`
    // ------- iPad Air 11" M2 ----------
    case `iPad Air 11" M2 Blue`
    case `iPad Air 11" M2 Purple`
    case `iPad Air 11" M2 Space Gray`
    case `iPad Air 11" M2 Stardust`
    // ------- iPad Air 13" M2 ----------
    case `iPad Air 13" M2 Blue`
    case `iPad Air 13" M2 Purple`
    case `iPad Air 13" M2 Space Gray`
    case `iPad Air 13" M2 Stardust`
    // ------- iPad Pro 11" M4 ----------
    case `iPad Pro 11" M4 Silver`
    case `iPad Pro 11" M4 Space Gray`
    // ------- iPad Pro 13" M4 ----------
    case `iPad Pro 13" M4 Silver`
    case `iPad Pro 13" M4 Space Gray`

    public var id: String {
        switch self {
        case .`iPad 9th Gen Silver`:            return "iPad9thGenSilver"
        case .`iPad mini A17 Pro Starlight`:    return "iPadMiniA17ProStarlight"
        case .`iPad Air 11" M2 Blue`:           return "iPadAir11M2Blue"
        case .`iPad Air 11" M2 Purple`:         return "iPadAir11M2Purple"
        case .`iPad Air 11" M2 Space Gray`:     return "iPadAir11M2SpaceGray"
        case .`iPad Air 11" M2 Stardust`:       return "iPadAir11M2Stardust"
        case .`iPad Air 13" M2 Blue`:           return "iPadAir13M2Blue"
        case .`iPad Air 13" M2 Purple`:         return "iPadAir13M2Purple"
        case .`iPad Air 13" M2 Space Gray`:     return "iPadAir13M2SpaceGray"
        case .`iPad Air 13" M2 Stardust`:       return "iPadAir13M2Stardust"
        case .`iPad Pro 11" M4 Silver`:         return "iPadPro11M4Silver"
        case .`iPad Pro 11" M4 Space Gray`:     return "iPadPro11M4SpaceGray"
        case .`iPad Pro 13" M4 Silver`:         return "iPadPro13M4Silver"
        case .`iPad Pro 13" M4 Space Gray`:     return "iPadPro13M4SpaceGray"
        }
    }

    public var model: String {
        switch self {
        case .`iPad 9th Gen Silver`:                return "iPad 9th Gen"
        case .`iPad mini A17 Pro Starlight`:        return "iPad mini A17 Pro"
        case .`iPad Air 11" M2 Blue`,
             .`iPad Air 11" M2 Purple`,
             .`iPad Air 11" M2 Space Gray`,
             .`iPad Air 11" M2 Stardust`:           return "iPad Air 11\" M2"
        case .`iPad Air 13" M2 Blue`,
             .`iPad Air 13" M2 Purple`,
             .`iPad Air 13" M2 Space Gray`,
             .`iPad Air 13" M2 Stardust`:           return "iPad Air 13\" M2"
        case .`iPad Pro 11" M4 Silver`,
             .`iPad Pro 11" M4 Space Gray`:         return "iPad Pro 11\" M4"
        case .`iPad Pro 13" M4 Silver`,
             .`iPad Pro 13" M4 Space Gray`:         return "iPad Pro 13\" M4"
        }
    }

    public var shortID: String {
        switch self {
        case .`iPad 9th Gen Silver`:                return "iPad9thGen"
        case .`iPad mini A17 Pro Starlight`:        return "iPadMiniA17Pro"
        case .`iPad Air 11" M2 Blue`,
             .`iPad Air 11" M2 Purple`,
             .`iPad Air 11" M2 Space Gray`,
             .`iPad Air 11" M2 Stardust`:           return "iPadAir11M2"
        case .`iPad Air 13" M2 Blue`,
             .`iPad Air 13" M2 Purple`,
             .`iPad Air 13" M2 Space Gray`,
             .`iPad Air 13" M2 Stardust`:           return "iPadAir13M2"
        case .`iPad Pro 11" M4 Silver`,
             .`iPad Pro 11" M4 Space Gray`:         return "iPadPro11M4"
        case .`iPad Pro 13" M4 Silver`,
             .`iPad Pro 13" M4 Space Gray`:         return "iPadPro13M4"
        }
    }

    public var prettyName: String {
        switch self {
        case .`iPad 9th Gen Silver`:                return "Silver"
        case .`iPad mini A17 Pro Starlight`:        return "Starlight"
        case .`iPad Air 11" M2 Blue`:               return "Blue"
        case .`iPad Air 11" M2 Purple`:             return "Purple"
        case .`iPad Air 11" M2 Space Gray`:         return "Space Gray"
        case .`iPad Air 11" M2 Stardust`:           return "Stardust"
        case .`iPad Air 13" M2 Blue`:               return "Blue"
        case .`iPad Air 13" M2 Purple`:             return "Purple"
        case .`iPad Air 13" M2 Space Gray`:         return "Space Gray"
        case .`iPad Air 13" M2 Stardust`:           return "Stardust"
        case .`iPad Pro 11" M4 Silver`:             return "Silver"
        case .`iPad Pro 11" M4 Space Gray`:         return "Space Gray"
        case .`iPad Pro 13" M4 Silver`:             return "Silver"
        case .`iPad Pro 13" M4 Space Gray`:         return "Space Gray"
        }
    }

    public var runDestination: String {
        switch self {
        case .`iPad 9th Gen Silver`:                return "iPad (9th generation)"
        case .`iPad mini A17 Pro Starlight`:        return "iPad mini (A17 Pro)"
        case .`iPad Air 11" M2 Blue`,
             .`iPad Air 11" M2 Purple`,
             .`iPad Air 11" M2 Space Gray`,
             .`iPad Air 11" M2 Stardust`:           return "iPad Air 11-inch (M2)"
        case .`iPad Air 13" M2 Blue`,
             .`iPad Air 13" M2 Purple`,
             .`iPad Air 13" M2 Space Gray`,
             .`iPad Air 13" M2 Stardust`:           return "iPad Air 13-inch (M2)"
        case .`iPad Pro 11" M4 Silver`,
             .`iPad Pro 11" M4 Space Gray`:         return "iPad Pro 11-inch (M5)"
        case .`iPad Pro 13" M4 Silver`,
             .`iPad Pro 13" M4 Space Gray`:         return "iPad Pro 13-inch (M5)"
        }
    }

    public var scale: CGFloat {
        switch self {
        case .`iPad 9th Gen Silver`:                return 0.88
        case .`iPad mini A17 Pro Starlight`:        return 0.89
        case .`iPad Air 11" M2 Blue`,
             .`iPad Air 11" M2 Purple`,
             .`iPad Air 11" M2 Space Gray`,
             .`iPad Air 11" M2 Stardust`:           return 0.9025
        case .`iPad Air 13" M2 Blue`,
             .`iPad Air 13" M2 Purple`,
             .`iPad Air 13" M2 Space Gray`,
             .`iPad Air 13" M2 Stardust`:           return 0.92
        case .`iPad Pro 11" M4 Silver`,
             .`iPad Pro 11" M4 Space Gray`:         return 0.92
        case .`iPad Pro 13" M4 Silver`,
             .`iPad Pro 13" M4 Space Gray`:         return 0.92
        }
    }

    public var verticalOffset: CGFloat {
        switch self {
        default: return 0
        }
    }
}

//
//  MacBezel.swift
//  HarnessKitTransform
//

import Foundation

public enum MacBezel: BezelDescriptor {
    // ------- MacBook Air 13 4th-gen ----------
    case `Macbook Air 13" 4th-gen Midnight`
    // ------- MacBook Pro 14 M4 ----------
    case `Macbook Pro 14" M4 Silver`
    // ------- MacBook Pro 16 M4 ----------
    case `Macbook Pro 16" M4 Silver`
    // ------- iMac 24" ----------
    case `iMac 24" Silver`

    public var id: String {
        switch self {
        case .`Macbook Air 13" 4th-gen Midnight`:   return "MacbookAir134thgenMidnight"
        case .`Macbook Pro 14" M4 Silver`:          return "MacbookPro14M4Silver"
        case .`Macbook Pro 16" M4 Silver`:          return "MacbookPro16M4Silver"
        case .`iMac 24" Silver`:                    return "iMac24Silver"
        }
    }

    public var shortID: String {
        switch self {
        case .`Macbook Air 13" 4th-gen Midnight`:   return "MacbookAir134thGen"
        case .`Macbook Pro 14" M4 Silver`:          return "MacbookPro14M4"
        case .`Macbook Pro 16" M4 Silver`:          return "MacbookPro16M4"
        case .`iMac 24" Silver`:                    return "iMac24"
        }
    }

    public var model: String {
        switch self {
        case .`Macbook Air 13" 4th-gen Midnight`:   return "Macbook Air 13\" 4-th Gen"
        case .`Macbook Pro 14" M4 Silver`:          return "Macbook Pro 14\" M4"
        case .`Macbook Pro 16" M4 Silver`:          return "Macbook Pro 16\" M4"
        case .`iMac 24" Silver`:                    return "iMac 24\""
        }
    }

    public var prettyName: String {
        switch self {
        case .`Macbook Air 13" 4th-gen Midnight`:   return "Midnight"
        case .`Macbook Pro 14" M4 Silver`:          return "Silver"
        case .`Macbook Pro 16" M4 Silver`:          return "Silver"
        case .`iMac 24" Silver`:                    return "Silver"
        }
    }

    public var runDestination: String {
        return "My Mac"
    }

    public var scale: CGFloat {
        switch self {
        case .`Macbook Air 13" 4th-gen Midnight`:   return 0.72
        case .`Macbook Pro 14" M4 Silver`:          return 0.76
        case .`Macbook Pro 16" M4 Silver`:          return 0.79
        case .`iMac 24" Silver`:                    return 0.73
        }
    }

    public var verticalOffset: CGFloat {
        switch self {
        case .`Macbook Air 13" 4th-gen Midnight`:   return 14
        case .`Macbook Pro 14" M4 Silver`:          return -15
        case .`Macbook Pro 16" M4 Silver`:          return -14
        case .`iMac 24" Silver`:                    return 250
        }
    }
}

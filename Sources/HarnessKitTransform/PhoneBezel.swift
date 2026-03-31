//
//  PhoneBezel.swift
//  HarnessKitTransform
//

import Foundation

public enum PhoneBezel: BezelDescriptor {
    // ------- iPhone 17 Pro Max ----------
    case `iPhone 17 Pro Max Cosmic Orange`
    case `iPhone 17 Pro Max Deep Blue`
    case `iPhone 17 Pro Max Silver`
    // ------- iPhone 17 Pro ----------
    case `iPhone 17 Pro Cosmic Orange`
    case `iPhone 17 Pro Deep Blue`
    case `iPhone 17 Pro Silver`
    // ------- iPhone 17 ----------
    case `iPhone 17 Black`
    case `iPhone 17 Lavender`
    case `iPhone 17 Mist Blue`
    case `iPhone 17 Sage`
    case `iPhone 17 White`
    // ------- iPhone Air ----------
    case `iPhone Air Cloud White`
    case `iPhone Air Light Gold`
    case `iPhone Air Sky Blue`
    case `iPhone Air Space Black`
    // ------- iPhone 16 Pro Max ----------
    case `iPhone 16 Pro Max Black Titanium`
    case `iPhone 16 Pro Max Desert Titanium`
    case `iPhone 16 Pro Max Natural Titanium`
    case `iPhone 16 Pro Max White Titanium`
    // ------- iPhone 16 Pro ----------
    case `iPhone 16 Pro Black Titanium`
    case `iPhone 16 Pro Desert Titanium`
    case `iPhone 16 Pro Natural Titanium`
    case `iPhone 16 Pro White Titanium`
    // ------- iPhone 16 Plus ----------
    case `iPhone 16 Plus Black`
    case `iPhone 16 Plus Pink`
    case `iPhone 16 Plus Teal`
    case `iPhone 16 Plus Ultramarine`
    case `iPhone 16 Plus White`
    // ------- iPhone 16 ----------
    case `iPhone 16 Black`
    case `iPhone 16 Pink`
    case `iPhone 16 Teal`
    case `iPhone 16 Ultramarine`
    case `iPhone 16 White`

    public var id: String {
        switch self {
        case .`iPhone 17 Pro Max Cosmic Orange`:    return "iPhone17ProMaxCosmicOrange"
        case .`iPhone 17 Pro Max Deep Blue`:        return "iPhone17ProMaxDeepBlue"
        case .`iPhone 17 Pro Max Silver`:           return "iPhone17ProMaxSilver"
        case .`iPhone 17 Pro Cosmic Orange`:        return "iPhone17ProCosmicOrange"
        case .`iPhone 17 Pro Deep Blue`:            return "iPhone17ProDeepBlue"
        case .`iPhone 17 Pro Silver`:               return "iPhone17ProSilver"
        case .`iPhone 17 Black`:                    return "iPhone17Black"
        case .`iPhone 17 Lavender`:                 return "iPhone17Lavender"
        case .`iPhone 17 Mist Blue`:                return "iPhone17MistBlue"
        case .`iPhone 17 Sage`:                     return "iPhone17Sage"
        case .`iPhone 17 White`:                    return "iPhone17White"
        case .`iPhone Air Cloud White`:             return "iPhoneAirCloudWhite"
        case .`iPhone Air Light Gold`:              return "iPhoneAirLightGold"
        case .`iPhone Air Sky Blue`:                return "iPhoneAirSkyBlue"
        case .`iPhone Air Space Black`:             return "iPhoneAirSpaceBlack"
        case .`iPhone 16 Pro Max Black Titanium`:   return "iPhone16ProMaxBlackTitanium"
        case .`iPhone 16 Pro Max Desert Titanium`:  return "iPhone16ProMaxDesertTitanium"
        case .`iPhone 16 Pro Max Natural Titanium`: return "iPhone16ProMaxNaturalTitanium"
        case .`iPhone 16 Pro Max White Titanium`:   return "iPhone16ProMaxWhiteTitanium"
        case .`iPhone 16 Pro Black Titanium`:       return "iPhone16ProBlackTitanium"
        case .`iPhone 16 Pro Desert Titanium`:      return "iPhone16ProDesertTitanium"
        case .`iPhone 16 Pro Natural Titanium`:     return "iPhone16ProNaturalTitanium"
        case .`iPhone 16 Pro White Titanium`:       return "iPhone16ProWhiteTitanium"
        case .`iPhone 16 Plus Black`:               return "iPhone16PlusBlack"
        case .`iPhone 16 Plus Pink`:                return "iPhone16PlusPink"
        case .`iPhone 16 Plus Teal`:                return "iPhone16PlusTeal"
        case .`iPhone 16 Plus Ultramarine`:         return "iPhone16PlusUltramarine"
        case .`iPhone 16 Plus White`:               return "iPhone16PlusWhite"
        case .`iPhone 16 Black`:                    return "iPhone16Black"
        case .`iPhone 16 Pink`:                     return "iPhone16Pink"
        case .`iPhone 16 Teal`:                     return "iPhone16Teal"
        case .`iPhone 16 Ultramarine`:              return "iPhone16Ultramarine"
        case .`iPhone 16 White`:                    return "iPhone16White"
        }
    }

    public var model: String {
        switch self {
        case .`iPhone 17 Pro Max Cosmic Orange`,
             .`iPhone 17 Pro Max Deep Blue`,
             .`iPhone 17 Pro Max Silver`:           return "iPhone 17 Pro Max"
        case .`iPhone 17 Pro Cosmic Orange`,
             .`iPhone 17 Pro Deep Blue`,
             .`iPhone 17 Pro Silver`:               return "iPhone 17 Pro"
        case .`iPhone 17 Black`,
             .`iPhone 17 Lavender`,
             .`iPhone 17 Mist Blue`,
             .`iPhone 17 Sage`,
             .`iPhone 17 White`:                    return "iPhone 17"
        case .`iPhone Air Cloud White`,
             .`iPhone Air Light Gold`,
             .`iPhone Air Sky Blue`,
             .`iPhone Air Space Black`:             return "iPhone Air"
        case .`iPhone 16 Pro Max Black Titanium`,
             .`iPhone 16 Pro Max Desert Titanium`,
             .`iPhone 16 Pro Max Natural Titanium`,
             .`iPhone 16 Pro Max White Titanium`:   return "iPhone 16 Pro Max"
        case .`iPhone 16 Pro Black Titanium`,
             .`iPhone 16 Pro Desert Titanium`,
             .`iPhone 16 Pro Natural Titanium`,
             .`iPhone 16 Pro White Titanium`:       return "iPhone 16 Pro"
        case .`iPhone 16 Plus Black`,
             .`iPhone 16 Plus Pink`,
             .`iPhone 16 Plus Teal`,
             .`iPhone 16 Plus Ultramarine`,
             .`iPhone 16 Plus White`:               return "iPhone 16 Plus"
        case .`iPhone 16 Black`,
             .`iPhone 16 Pink`,
             .`iPhone 16 Teal`,
             .`iPhone 16 Ultramarine`,
             .`iPhone 16 White`:                    return "iPhone 16"
        }
    }

    public var shortID: String {
        switch self {
        case .`iPhone 17 Pro Max Cosmic Orange`,
             .`iPhone 17 Pro Max Deep Blue`,
             .`iPhone 17 Pro Max Silver`:           return "iPhone17ProMax"
        case .`iPhone 17 Pro Cosmic Orange`,
             .`iPhone 17 Pro Deep Blue`,
             .`iPhone 17 Pro Silver`:               return "iPhone17Pro"
        case .`iPhone 17 Black`,
             .`iPhone 17 Lavender`,
             .`iPhone 17 Mist Blue`,
             .`iPhone 17 Sage`,
             .`iPhone 17 White`:                    return "iPhone17"
        case .`iPhone Air Cloud White`,
             .`iPhone Air Light Gold`,
             .`iPhone Air Sky Blue`,
             .`iPhone Air Space Black`:             return "iPhoneAir"
        case .`iPhone 16 Pro Max Black Titanium`,
             .`iPhone 16 Pro Max Desert Titanium`,
             .`iPhone 16 Pro Max Natural Titanium`,
             .`iPhone 16 Pro Max White Titanium`:   return "iPhone16ProMax"
        case .`iPhone 16 Pro Black Titanium`,
             .`iPhone 16 Pro Desert Titanium`,
             .`iPhone 16 Pro Natural Titanium`,
             .`iPhone 16 Pro White Titanium`:       return "iPhone16Pro"
        case .`iPhone 16 Plus Black`,
             .`iPhone 16 Plus Pink`,
             .`iPhone 16 Plus Teal`,
             .`iPhone 16 Plus Ultramarine`,
             .`iPhone 16 Plus White`:               return "iPhone16Plus"
        case .`iPhone 16 Black`,
             .`iPhone 16 Pink`,
             .`iPhone 16 Teal`,
             .`iPhone 16 Ultramarine`,
             .`iPhone 16 White`:                    return "iPhone16"
        }
    }

    public var prettyName: String {
        switch self {
        case .`iPhone 17 Pro Max Cosmic Orange`:    return "Cosmic Orange"
        case .`iPhone 17 Pro Max Deep Blue`:        return "Deep Blue"
        case .`iPhone 17 Pro Max Silver`:           return "Silver"
        case .`iPhone 17 Pro Cosmic Orange`:        return "Cosmic Orange"
        case .`iPhone 17 Pro Deep Blue`:            return "Deep Blue"
        case .`iPhone 17 Pro Silver`:               return "Silver"
        case .`iPhone 17 Black`:                    return "Black"
        case .`iPhone 17 Lavender`:                 return "Lavender"
        case .`iPhone 17 Mist Blue`:                return "Mist Blue"
        case .`iPhone 17 Sage`:                     return "Sage"
        case .`iPhone 17 White`:                    return "White"
        case .`iPhone Air Cloud White`:             return "Cloud White"
        case .`iPhone Air Light Gold`:              return "Light Gold"
        case .`iPhone Air Sky Blue`:                return "Sky Blue"
        case .`iPhone Air Space Black`:             return "Space Black"
        case .`iPhone 16 Pro Max Black Titanium`:   return "Black Titanium"
        case .`iPhone 16 Pro Max Desert Titanium`:  return "Desert Titanium"
        case .`iPhone 16 Pro Max Natural Titanium`: return "Natural Titanium"
        case .`iPhone 16 Pro Max White Titanium`:   return "White Titanium"
        case .`iPhone 16 Pro Black Titanium`:       return "Black Titanium"
        case .`iPhone 16 Pro Desert Titanium`:      return "Desert Titanium"
        case .`iPhone 16 Pro Natural Titanium`:     return "Natural Titanium"
        case .`iPhone 16 Pro White Titanium`:       return "White Titanium"
        case .`iPhone 16 Plus Black`:               return "Black"
        case .`iPhone 16 Plus Pink`:                return "Pink"
        case .`iPhone 16 Plus Teal`:                return "Teal"
        case .`iPhone 16 Plus Ultramarine`:         return "Ultramarine"
        case .`iPhone 16 Plus White`:               return "White"
        case .`iPhone 16 Black`:                    return "Black"
        case .`iPhone 16 Pink`:                     return "Pink"
        case .`iPhone 16 Teal`:                     return "Teal"
        case .`iPhone 16 Ultramarine`:              return "Ultramarine"
        case .`iPhone 16 White`:                    return "White"
        }
    }

    public var runDestination: String {
        switch self {
        case .`iPhone 17 Pro Max Cosmic Orange`,
             .`iPhone 17 Pro Max Deep Blue`,
             .`iPhone 17 Pro Max Silver`:           return "iPhone 17 Pro Max"
        case .`iPhone 17 Pro Cosmic Orange`,
             .`iPhone 17 Pro Deep Blue`,
             .`iPhone 17 Pro Silver`:               return "iPhone 17 Pro"
        case .`iPhone 17 Black`,
             .`iPhone 17 Lavender`,
             .`iPhone 17 Mist Blue`,
             .`iPhone 17 Sage`,
             .`iPhone 17 White`:                    return "iPhone 17"
        case .`iPhone Air Cloud White`,
             .`iPhone Air Light Gold`,
             .`iPhone Air Sky Blue`,
             .`iPhone Air Space Black`:             return "iPhone Air"
        case .`iPhone 16 Pro Max Black Titanium`,
             .`iPhone 16 Pro Max Desert Titanium`,
             .`iPhone 16 Pro Max Natural Titanium`,
             .`iPhone 16 Pro Max White Titanium`:   return "iPhone 16 Pro Max"
        case .`iPhone 16 Pro Black Titanium`,
             .`iPhone 16 Pro Desert Titanium`,
             .`iPhone 16 Pro Natural Titanium`,
             .`iPhone 16 Pro White Titanium`:       return "iPhone 16 Pro"
        case .`iPhone 16 Plus Black`,
             .`iPhone 16 Plus Pink`,
             .`iPhone 16 Plus Teal`,
             .`iPhone 16 Plus Ultramarine`,
             .`iPhone 16 Plus White`:               return "iPhone 16 Plus"
        case .`iPhone 16 Black`,
             .`iPhone 16 Pink`,
             .`iPhone 16 Teal`,
             .`iPhone 16 Ultramarine`,
             .`iPhone 16 White`:                    return "iPhone 16"
        }
    }

    public var scale: CGFloat {
        switch self {
        case .`iPhone 17 Pro Max Cosmic Orange`,
             .`iPhone 17 Pro Max Deep Blue`,
             .`iPhone 17 Pro Max Silver`:           return 0.9575
        case .`iPhone 17 Pro Cosmic Orange`,
             .`iPhone 17 Pro Deep Blue`,
             .`iPhone 17 Pro Silver`:               return 0.95
        case .`iPhone 17 Black`,
             .`iPhone 17 Lavender`,
             .`iPhone 17 Mist Blue`,
             .`iPhone 17 Sage`,
             .`iPhone 17 White`:                    return 0.9525
        case .`iPhone Air Cloud White`,
             .`iPhone Air Light Gold`,
             .`iPhone Air Sky Blue`,
             .`iPhone Air Space Black`:             return 0.95
        case .`iPhone 16 Pro Max Black Titanium`,
             .`iPhone 16 Pro Max Desert Titanium`,
             .`iPhone 16 Pro Max Natural Titanium`,
             .`iPhone 16 Pro Max White Titanium`:   return 0.9575
        case .`iPhone 16 Pro Black Titanium`,
             .`iPhone 16 Pro Desert Titanium`,
             .`iPhone 16 Pro Natural Titanium`,
             .`iPhone 16 Pro White Titanium`:       return 0.95
        case .`iPhone 16 Plus Black`,
             .`iPhone 16 Plus Pink`,
             .`iPhone 16 Plus Teal`,
             .`iPhone 16 Plus Ultramarine`,
             .`iPhone 16 Plus White`:               return 0.945
        case .`iPhone 16 Black`,
             .`iPhone 16 Pink`,
             .`iPhone 16 Teal`,
             .`iPhone 16 Ultramarine`,
             .`iPhone 16 White`:                    return 0.935
        }
    }

    public var verticalOffset: CGFloat {
        return 0
    }
}

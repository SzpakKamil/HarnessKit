//
//  WatchBezel.swift
//  HarnessKitTransform
//

import Foundation

public enum WatchBezel: BezelDescriptor {
    // ------- Apple Watch S11 42mm — Sport Loop ----------
    case `Apple Watch S11 42mm Aluminum Jet Black Sport Loop Dark Grey`
    case `Apple Watch S11 42mm Aluminum Rose Gold Sport Loop Purple Fog`
    case `Apple Watch S11 42mm Aluminum Silver Sport Loop Forest`
    case `Apple Watch S11 42mm Aluminum Silver Sport Loop Neon Yellow`
    case `Apple Watch S11 42mm Aluminum Space Gray Sport Loop Anchor Blue`
    case `Apple Watch S11 42mm Aluminum Space Gray Sport Loop Forest`
    // ------- Apple Watch S11 42mm — Sport Band ----------
    case `Apple Watch S11 42mm Aluminum Jet Black Sport Band Black`
    case `Apple Watch S11 42mm Aluminum Rose Gold Sport Band Light Blush`
    case `Apple Watch S11 42mm Aluminum Silver Sport Band Neon Yellow`
    case `Apple Watch S11 42mm Aluminum Silver Sport Band Purple Fog`
    case `Apple Watch S11 42mm Aluminum Space Gray Sport Band Anchor Blue`
    case `Apple Watch S11 42mm Aluminum Space Gray Sport Band Black`
    case `Apple Watch S11 42mm Titanium Gold Sport Band Light Blush`
    case `Apple Watch S11 42mm Titanium Gold Sport Band Purple Fog`
    case `Apple Watch S11 42mm Titanium Natural Sport Band Stone Gray`
    case `Apple Watch S11 42mm Titanium Slate Sport Band Black`
    // ------- Apple Watch S11 42mm — Milanese Loop ----------
    case `Apple Watch S11 42mm Titanium Gold Milanese Loop`
    case `Apple Watch S11 42mm Titanium Natural Milanese Loop`
    case `Apple Watch S11 42mm Titanium Slate Milanese Loop`
    // ------- Apple Watch S11 42mm — Magnetic Link ----------
    case `Apple Watch S11 42mm Titanium Gold Magnetic Link Sage Gray`
    case `Apple Watch S11 42mm Titanium Natural Magnetic Link Carmel`
    case `Apple Watch S11 42mm Titanium Slate Magnetic Link Navy`
    // ------- Apple Watch S11 46mm — Sport Loop ----------
    case `Apple Watch S11 46mm Aluminum Jet Black Sport Loop Dark Grey`
    case `Apple Watch S11 46mm Aluminum Rose Gold Sport Loop Purple Fog`
    case `Apple Watch S11 46mm Aluminum Silver Sport Loop Forest`
    case `Apple Watch S11 46mm Aluminum Silver Sport Loop Neon Yellow`
    case `Apple Watch S11 46mm Aluminum Space Gray Sport Loop Anchor Blue`
    case `Apple Watch S11 46mm Aluminum Space Gray Sport Loop Forest`
    // ------- Apple Watch S11 46mm — Sport Band ----------
    case `Apple Watch S11 46mm Aluminum Jet Black Sport Band Black`
    case `Apple Watch S11 46mm Aluminum Rose Gold Sport Band Light Blush`
    case `Apple Watch S11 46mm Aluminum Silver Sport Band Neon Yellow`
    case `Apple Watch S11 46mm Aluminum Silver Sport Band Purple Fog`
    case `Apple Watch S11 46mm Aluminum Space Gray Sport Band Anchor Blue`
    case `Apple Watch S11 46mm Aluminum Space Gray Sport Band Black`
    case `Apple Watch S11 46mm Titanium Gold Sport Band Light Blush`
    case `Apple Watch S11 46mm Titanium Gold Sport Band Purple Fog`
    case `Apple Watch S11 46mm Titanium Natural Sport Band Stone Gray`
    case `Apple Watch S11 46mm Titanium Slate Sport Band Black`
    // ------- Apple Watch S11 46mm — Milanese Loop ----------
    case `Apple Watch S11 46mm Titanium Gold Milanese Loop`
    case `Apple Watch S11 46mm Titanium Natural Milanese Loop`
    case `Apple Watch S11 46mm Titanium Slate Milanese Loop`
    // ------- Apple Watch S11 46mm — Magnetic Link ----------
    case `Apple Watch S11 46mm Titanium Gold Magnetic Link Sage Gray`
    case `Apple Watch S11 46mm Titanium Natural Magnetic Link Carmel`
    case `Apple Watch S11 46mm Titanium Slate Magnetic Link Navy`
    // ------- Apple Watch Ultra 3 — Alpine Loop ----------
    case `Apple Watch Ultra 3 Black Alpine Loop Black`
    case `Apple Watch Ultra 3 Black Alpine Loop Light Blue`
    case `Apple Watch Ultra 3 Natural Alpine Loop Light Blue`
    case `Apple Watch Ultra 3 Natural Alpine Loop Terra Cotta`
    // ------- Apple Watch Ultra 3 — Milanese Loop ----------
    case `Apple Watch Ultra 3 Black Milanese Loop`
    case `Apple Watch Ultra 3 Natural Milanese Loop`
    // ------- Apple Watch Ultra 3 — Ocean Band ----------
    case `Apple Watch Ultra 3 Black Ocean Band Anchor Blue`
    case `Apple Watch Ultra 3 Black Ocean Band Black`
    case `Apple Watch Ultra 3 Natural Ocean Band Anchor Blue`
    case `Apple Watch Ultra 3 Natural Ocean Band Neon Green`
    // ------- Apple Watch Ultra 3 — Trail Loop ----------
    case `Apple Watch Ultra 3 Black Trail Loop Black Charcoal`
    case `Apple Watch Ultra 3 Natural Trail Loop Blue Bright Blue`
    case `Apple Watch Ultra 3 Natural Trail Loop Green Neon`

    // MARK: id

    public var id: String {
        switch self {
        case .`Apple Watch S11 42mm Aluminum Jet Black Sport Loop Dark Grey`:        return "AppleWatchS1142mmAluminumJetBlackSportLoopDarkGrey"
        case .`Apple Watch S11 42mm Aluminum Rose Gold Sport Loop Purple Fog`:       return "AppleWatchS1142mmAluminumRoseGoldSportLoopPurpleFog"
        case .`Apple Watch S11 42mm Aluminum Silver Sport Loop Forest`:              return "AppleWatchS1142mmAluminumSilverSportLoopForest"
        case .`Apple Watch S11 42mm Aluminum Silver Sport Loop Neon Yellow`:         return "AppleWatchS1142mmAluminumSilverSportLoopNeonYellow"
        case .`Apple Watch S11 42mm Aluminum Space Gray Sport Loop Anchor Blue`:     return "AppleWatchS1142mmAluminumSpaceGraySportLoopAnchorBlue"
        case .`Apple Watch S11 42mm Aluminum Space Gray Sport Loop Forest`:          return "AppleWatchS1142mmAluminumSpaceGraySportLoopForest"
        case .`Apple Watch S11 42mm Aluminum Jet Black Sport Band Black`:            return "AppleWatchS1142mmAluminumJetBlackSportBandBlack"
        case .`Apple Watch S11 42mm Aluminum Rose Gold Sport Band Light Blush`:      return "AppleWatchS1142mmAluminumRoseGoldSportBandLightBlush"
        case .`Apple Watch S11 42mm Aluminum Silver Sport Band Neon Yellow`:         return "AppleWatchS1142mmAluminumSilverSportBandNeonYellow"
        case .`Apple Watch S11 42mm Aluminum Silver Sport Band Purple Fog`:          return "AppleWatchS1142mmAluminumSilverSportBandPurpleFog"
        case .`Apple Watch S11 42mm Aluminum Space Gray Sport Band Anchor Blue`:     return "AppleWatchS1142mmAluminumSpaceGraySportBandAnchorBlue"
        case .`Apple Watch S11 42mm Aluminum Space Gray Sport Band Black`:           return "AppleWatchS1142mmAluminumSpaceGraySportBandBlack"
        case .`Apple Watch S11 42mm Titanium Gold Sport Band Light Blush`:           return "AppleWatchS1142mmTitaniumGoldSportBandLightBlush"
        case .`Apple Watch S11 42mm Titanium Gold Sport Band Purple Fog`:            return "AppleWatchS1142mmTitaniumGoldSportBandPurpleFog"
        case .`Apple Watch S11 42mm Titanium Natural Sport Band Stone Gray`:         return "AppleWatchS1142mmTitaniumNaturalSportBandStoneGray"
        case .`Apple Watch S11 42mm Titanium Slate Sport Band Black`:                return "AppleWatchS1142mmTitaniumSlateSportBandBlack"
        case .`Apple Watch S11 42mm Titanium Gold Milanese Loop`:                    return "AppleWatchS1142mmTitaniumGoldMilaneseLoop"
        case .`Apple Watch S11 42mm Titanium Natural Milanese Loop`:                 return "AppleWatchS1142mmTitaniumNaturalMilaneseLoop"
        case .`Apple Watch S11 42mm Titanium Slate Milanese Loop`:                   return "AppleWatchS1142mmTitaniumSlateMilaneseLoop"
        case .`Apple Watch S11 42mm Titanium Gold Magnetic Link Sage Gray`:          return "AppleWatchS1142mmTitaniumGoldMagneticLinkSageGray"
        case .`Apple Watch S11 42mm Titanium Natural Magnetic Link Carmel`:          return "AppleWatchS1142mmTitaniumNaturalMagneticLinkCarmel"
        case .`Apple Watch S11 42mm Titanium Slate Magnetic Link Navy`:              return "AppleWatchS1142mmTitaniumSlateMagneticLinkNavy"
        case .`Apple Watch S11 46mm Aluminum Jet Black Sport Loop Dark Grey`:        return "AppleWatchS1146mmAluminumJetBlackSportLoopDarkGrey"
        case .`Apple Watch S11 46mm Aluminum Rose Gold Sport Loop Purple Fog`:       return "AppleWatchS1146mmAluminumRoseGoldSportLoopPurpleFog"
        case .`Apple Watch S11 46mm Aluminum Silver Sport Loop Forest`:              return "AppleWatchS1146mmAluminumSilverSportLoopForest"
        case .`Apple Watch S11 46mm Aluminum Silver Sport Loop Neon Yellow`:         return "AppleWatchS1146mmAluminumSilverSportLoopNeonYellow"
        case .`Apple Watch S11 46mm Aluminum Space Gray Sport Loop Anchor Blue`:     return "AppleWatchS1146mmAluminumSpaceGraySportLoopAnchorBlue"
        case .`Apple Watch S11 46mm Aluminum Space Gray Sport Loop Forest`:          return "AppleWatchS1146mmAluminumSpaceGraySportLoopForest"
        case .`Apple Watch S11 46mm Aluminum Jet Black Sport Band Black`:            return "AppleWatchS1146mmAluminumJetBlackSportBandBlack"
        case .`Apple Watch S11 46mm Aluminum Rose Gold Sport Band Light Blush`:      return "AppleWatchS1146mmAluminumRoseGoldSportBandLightBlush"
        case .`Apple Watch S11 46mm Aluminum Silver Sport Band Neon Yellow`:         return "AppleWatchS1146mmAluminumSilverSportBandNeonYellow"
        case .`Apple Watch S11 46mm Aluminum Silver Sport Band Purple Fog`:          return "AppleWatchS1146mmAluminumSilverSportBandPurpleFog"
        case .`Apple Watch S11 46mm Aluminum Space Gray Sport Band Anchor Blue`:     return "AppleWatchS1146mmAluminumSpaceGraySportBandAnchorBlue"
        case .`Apple Watch S11 46mm Aluminum Space Gray Sport Band Black`:           return "AppleWatchS1146mmAluminumSpaceGraySportBandBlack"
        case .`Apple Watch S11 46mm Titanium Gold Sport Band Light Blush`:           return "AppleWatchS1146mmTitaniumGoldSportBandLightBlush"
        case .`Apple Watch S11 46mm Titanium Gold Sport Band Purple Fog`:            return "AppleWatchS1146mmTitaniumGoldSportBandPurpleFog"
        case .`Apple Watch S11 46mm Titanium Natural Sport Band Stone Gray`:         return "AppleWatchS1146mmTitaniumNaturalSportBandStoneGray"
        case .`Apple Watch S11 46mm Titanium Slate Sport Band Black`:                return "AppleWatchS1146mmTitaniumSlateSportBandBlack"
        case .`Apple Watch S11 46mm Titanium Gold Milanese Loop`:                    return "AppleWatchS1146mmTitaniumGoldMilaneseLoop"
        case .`Apple Watch S11 46mm Titanium Natural Milanese Loop`:                 return "AppleWatchS1146mmTitaniumNaturalMilaneseLoop"
        case .`Apple Watch S11 46mm Titanium Slate Milanese Loop`:                   return "AppleWatchS1146mmTitaniumSlateMilaneseLoop"
        case .`Apple Watch S11 46mm Titanium Gold Magnetic Link Sage Gray`:          return "AppleWatchS1146mmTitaniumGoldMagneticLinkSageGray"
        case .`Apple Watch S11 46mm Titanium Natural Magnetic Link Carmel`:          return "AppleWatchS1146mmTitaniumNaturalMagneticLinkCarmel"
        case .`Apple Watch S11 46mm Titanium Slate Magnetic Link Navy`:              return "AppleWatchS1146mmTitaniumSlateMagneticLinkNavy"
        case .`Apple Watch Ultra 3 Black Alpine Loop Black`:                         return "AppleWatchUltra3BlackAlpineLoopBlack"
        case .`Apple Watch Ultra 3 Black Alpine Loop Light Blue`:                    return "AppleWatchUltra3BlackAlpineLoopLightBlue"
        case .`Apple Watch Ultra 3 Natural Alpine Loop Light Blue`:                  return "AppleWatchUltra3NaturalAlpineLoopLightBlue"
        case .`Apple Watch Ultra 3 Natural Alpine Loop Terra Cotta`:                 return "AppleWatchUltra3NaturalAlpineLoopTerraCotta"
        case .`Apple Watch Ultra 3 Black Milanese Loop`:                             return "AppleWatchUltra3BlackMilaneseLoop"
        case .`Apple Watch Ultra 3 Natural Milanese Loop`:                           return "AppleWatchUltra3NaturalMilaneseLoop"
        case .`Apple Watch Ultra 3 Black Ocean Band Anchor Blue`:                    return "AppleWatchUltra3BlackOceanBandAnchorBlue"
        case .`Apple Watch Ultra 3 Black Ocean Band Black`:                          return "AppleWatchUltra3BlackOceanBandBlack"
        case .`Apple Watch Ultra 3 Natural Ocean Band Anchor Blue`:                  return "AppleWatchUltra3NaturalOceanBandAnchorBlue"
        case .`Apple Watch Ultra 3 Natural Ocean Band Neon Green`:                   return "AppleWatchUltra3NaturalOceanBandNeonGreen"
        case .`Apple Watch Ultra 3 Black Trail Loop Black Charcoal`:                 return "AppleWatchUltra3BlackTrailLoopBlackCharcoal"
        case .`Apple Watch Ultra 3 Natural Trail Loop Blue Bright Blue`:             return "AppleWatchUltra3NaturalTrailLoopBlueBrightBlue"
        case .`Apple Watch Ultra 3 Natural Trail Loop Green Neon`:                   return "AppleWatchUltra3NaturalTrailLoopGreenNeon"
        }
    }

    // MARK: shortID

    private static let _s11_42mm = [
        WatchBezel.`Apple Watch S11 42mm Aluminum Jet Black Sport Loop Dark Grey`,
        .`Apple Watch S11 42mm Aluminum Rose Gold Sport Loop Purple Fog`,
        .`Apple Watch S11 42mm Aluminum Silver Sport Loop Forest`,
        .`Apple Watch S11 42mm Aluminum Silver Sport Loop Neon Yellow`,
        .`Apple Watch S11 42mm Aluminum Space Gray Sport Loop Anchor Blue`,
        .`Apple Watch S11 42mm Aluminum Space Gray Sport Loop Forest`,
        .`Apple Watch S11 42mm Aluminum Jet Black Sport Band Black`,
        .`Apple Watch S11 42mm Aluminum Rose Gold Sport Band Light Blush`,
        .`Apple Watch S11 42mm Aluminum Silver Sport Band Neon Yellow`,
        .`Apple Watch S11 42mm Aluminum Silver Sport Band Purple Fog`,
        .`Apple Watch S11 42mm Aluminum Space Gray Sport Band Anchor Blue`,
        .`Apple Watch S11 42mm Aluminum Space Gray Sport Band Black`,
        .`Apple Watch S11 42mm Titanium Gold Sport Band Light Blush`,
        .`Apple Watch S11 42mm Titanium Gold Sport Band Purple Fog`,
        .`Apple Watch S11 42mm Titanium Natural Sport Band Stone Gray`,
        .`Apple Watch S11 42mm Titanium Slate Sport Band Black`,
        .`Apple Watch S11 42mm Titanium Gold Milanese Loop`,
        .`Apple Watch S11 42mm Titanium Natural Milanese Loop`,
        .`Apple Watch S11 42mm Titanium Slate Milanese Loop`,
        .`Apple Watch S11 42mm Titanium Gold Magnetic Link Sage Gray`,
        .`Apple Watch S11 42mm Titanium Natural Magnetic Link Carmel`,
        .`Apple Watch S11 42mm Titanium Slate Magnetic Link Navy`
    ]

    private static let _s11_46mm = [
        WatchBezel.`Apple Watch S11 46mm Aluminum Jet Black Sport Loop Dark Grey`,
        .`Apple Watch S11 46mm Aluminum Rose Gold Sport Loop Purple Fog`,
        .`Apple Watch S11 46mm Aluminum Silver Sport Loop Forest`,
        .`Apple Watch S11 46mm Aluminum Silver Sport Loop Neon Yellow`,
        .`Apple Watch S11 46mm Aluminum Space Gray Sport Loop Anchor Blue`,
        .`Apple Watch S11 46mm Aluminum Space Gray Sport Loop Forest`,
        .`Apple Watch S11 46mm Aluminum Jet Black Sport Band Black`,
        .`Apple Watch S11 46mm Aluminum Rose Gold Sport Band Light Blush`,
        .`Apple Watch S11 46mm Aluminum Silver Sport Band Neon Yellow`,
        .`Apple Watch S11 46mm Aluminum Silver Sport Band Purple Fog`,
        .`Apple Watch S11 46mm Aluminum Space Gray Sport Band Anchor Blue`,
        .`Apple Watch S11 46mm Aluminum Space Gray Sport Band Black`,
        .`Apple Watch S11 46mm Titanium Gold Sport Band Light Blush`,
        .`Apple Watch S11 46mm Titanium Gold Sport Band Purple Fog`,
        .`Apple Watch S11 46mm Titanium Natural Sport Band Stone Gray`,
        .`Apple Watch S11 46mm Titanium Slate Sport Band Black`,
        .`Apple Watch S11 46mm Titanium Gold Milanese Loop`,
        .`Apple Watch S11 46mm Titanium Natural Milanese Loop`,
        .`Apple Watch S11 46mm Titanium Slate Milanese Loop`,
        .`Apple Watch S11 46mm Titanium Gold Magnetic Link Sage Gray`,
        .`Apple Watch S11 46mm Titanium Natural Magnetic Link Carmel`,
        .`Apple Watch S11 46mm Titanium Slate Magnetic Link Navy`
    ]

    private static let _ultra3 = [
        WatchBezel.`Apple Watch Ultra 3 Black Alpine Loop Black`,
        .`Apple Watch Ultra 3 Black Alpine Loop Light Blue`,
        .`Apple Watch Ultra 3 Natural Alpine Loop Light Blue`,
        .`Apple Watch Ultra 3 Natural Alpine Loop Terra Cotta`,
        .`Apple Watch Ultra 3 Black Milanese Loop`,
        .`Apple Watch Ultra 3 Natural Milanese Loop`,
        .`Apple Watch Ultra 3 Black Ocean Band Anchor Blue`,
        .`Apple Watch Ultra 3 Black Ocean Band Black`,
        .`Apple Watch Ultra 3 Natural Ocean Band Anchor Blue`,
        .`Apple Watch Ultra 3 Natural Ocean Band Neon Green`,
        .`Apple Watch Ultra 3 Black Trail Loop Black Charcoal`,
        .`Apple Watch Ultra 3 Natural Trail Loop Blue Bright Blue`,
        .`Apple Watch Ultra 3 Natural Trail Loop Green Neon`
    ]

    public var shortID: String {
        if WatchBezel._s11_42mm.contains(self) { return "AppleWatchS1142mm" }
        if WatchBezel._s11_46mm.contains(self) { return "AppleWatchS1146mm" }
        return "AppleWatchUltra3"
    }

    public var model: String {
        if WatchBezel._s11_42mm.contains(self) { return "Apple Watch Series 11 44mm" }
        if WatchBezel._s11_46mm.contains(self) { return "Apple Watch  Series 11 46mm" }
        return "Apple Watch Ultra 3 49mm"
    }

    public var prettyName: String {
        // Strip the model prefix and return the variant part
        let prefix42 = "Apple Watch S11 42mm "
        let prefix46 = "Apple Watch S11 46mm "
        let prefixU3 = "Apple Watch Ultra 3 "
        let raw = String(describing: self)
        for prefix in [prefix42, prefix46, prefixU3] {
            if raw.hasPrefix(prefix) {
                return String(raw.dropFirst(prefix.count))
            }
        }
        return raw
    }

    public var runDestination: String {
        if WatchBezel._s11_42mm.contains(self) { return "Apple Watch Series 11 (44mm)" }
        if WatchBezel._s11_46mm.contains(self) { return "Apple Watch Series 11 (46mm)" }
        return "Apple Watch Ultra 3 (49mm)"
    }

    public var scale: CGFloat {
        if WatchBezel._ultra3.contains(self) { return 0.72 }
        return 0.75
    }

    public var verticalOffset: CGFloat { return 0 }
}

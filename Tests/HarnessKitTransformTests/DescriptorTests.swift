//
//  DescriptorTests.swift
//  HarnessKitTransformTests
//

import XCTest
@testable import HarnessKitTransform

final class DescriptorTests: XCTestCase {

    // MARK: - ParsedPadBezelName

    func testParsedPadBezelName_validFilename() {
        let parsed = ParsedPadBezelName.parse("device*iPadAir11^processors*M2+M3+M4^color*Blue.png")
        XCTAssertNotNil(parsed)
        XCTAssertEqual(parsed?.device, "iPadAir11")
        XCTAssertEqual(parsed?.processors, Set(["M2", "M3", "M4"]))
        XCTAssertEqual(parsed?.color, "Blue")
    }

    func testParsedPadBezelName_missingField_returnsNil() {
        // Missing processors field
        let parsed = ParsedPadBezelName.parse("device*iPadAir11^color*Blue.png")
        XCTAssertNil(parsed)
    }

    // MARK: - ParsedTVBezelName

    func testParsedTVBezelName_withGens() {
        let parsed = ParsedTVBezelName.parse("device*AppleTVFrameBox^gens*HD+4K1+4K2+4K3^color*Default.png")
        XCTAssertNotNil(parsed)
        XCTAssertEqual(parsed?.device, "AppleTVFrameBox")
        XCTAssertEqual(parsed?.generations, Set(["HD", "4K1", "4K2", "4K3"]))
        XCTAssertEqual(parsed?.color, "Default")
    }

    func testParsedTVBezelName_noGens_emptySet() {
        let parsed = ParsedTVBezelName.parse("device*AppleTVFrame^color*Default.png")
        XCTAssertNotNil(parsed)
        XCTAssertEqual(parsed?.generations, Set())
    }

    // MARK: - ParsedBezelName (Mac)

    func testParsedBezelName_macFormat() {
        let parsed = ParsedBezelName.parse("device*MacbookPro^size*14^models*M3+M4+M5^color*Silver^os*26^wallpaper*Default^appearance*Light.png")
        XCTAssertNotNil(parsed)
        XCTAssertEqual(parsed?.device, "MacbookPro")
        XCTAssertEqual(parsed?.size, "14")
        XCTAssertEqual(parsed?.models, Set(["M3", "M4", "M5"]))
        XCTAssertEqual(parsed?.color, "Silver")
        XCTAssertEqual(parsed?.osMajor, "26")
        XCTAssertEqual(parsed?.wallpaper, "Default")
        XCTAssertEqual(parsed?.appearance, "Light")
    }

    // MARK: - ParsedWatchBezelName

    func testParsedWatchBezelName_valid() {
        let parsed = ParsedWatchBezelName.parse("device*AppleWatch^series*S11^size*46^material*Titanium^color*Natural^band*SportBandBlack.png")
        XCTAssertNotNil(parsed)
        XCTAssertEqual(parsed?.series, "S11")
        XCTAssertEqual(parsed?.size, "46")
        XCTAssertEqual(parsed?.material, "Titanium")
        XCTAssertEqual(parsed?.color, "Natural")
        XCTAssertEqual(parsed?.band, "SportBandBlack")
    }

    func testParsedWatchBezelName_wrongDevice_returnsNil() {
        let parsed = ParsedWatchBezelName.parse("device*iPhone^series*S11^size*46^material*Titanium^color*Natural^band*SportBandBlack.png")
        XCTAssertNil(parsed)
    }

    // MARK: - DeviceDescriptor Codable

    func testDeviceDescriptor_decodesColors_array() throws {
        let json = """
        {"id":"iPhone16","model":"iPhone 16","colors":["Black","White"],"runDestination":"iPhone 16","scale":0.9,"verticalOffset":0,"screenCornerRadius":0.1}
        """.data(using: .utf8)!
        let descriptor = try JSONDecoder().decode(DeviceDescriptor.self, from: json)
        XCTAssertEqual(descriptor.colors, ["Black", "White"])
    }

    func testDeviceDescriptor_decodesColor_singular_backwardCompat() throws {
        let json = """
        {"id":"AppleTVFrame","model":"Apple TV","color":"Default","runDestination":"Apple TV 4K","scale":0.99,"verticalOffset":0,"screenCornerRadius":0}
        """.data(using: .utf8)!
        let descriptor = try JSONDecoder().decode(DeviceDescriptor.self, from: json)
        XCTAssertEqual(descriptor.colors, ["Default"])
    }

    func testDeviceDescriptor_allowsScreenshot_defaultsTrue() throws {
        let json = """
        {"id":"iPhone16","model":"iPhone 16","colors":["Black"],"runDestination":"iPhone 16","scale":0.9,"verticalOffset":0,"screenCornerRadius":0.1}
        """.data(using: .utf8)!
        let descriptor = try JSONDecoder().decode(DeviceDescriptor.self, from: json)
        XCTAssertTrue(descriptor.allowsScreenshot)
    }

    func testDeviceDescriptor_allowsScreenshot_decodedWhenFalse() throws {
        let json = """
        {"id":"AppleTVDecoration","model":"Apple TV (Decoration)","colors":["Default"],"runDestination":"Apple TV 4K","scale":1.0,"verticalOffset":0,"screenCornerRadius":0,"allowsScreenshot":false}
        """.data(using: .utf8)!
        let descriptor = try JSONDecoder().decode(DeviceDescriptor.self, from: json)
        XCTAssertFalse(descriptor.allowsScreenshot)
    }
}

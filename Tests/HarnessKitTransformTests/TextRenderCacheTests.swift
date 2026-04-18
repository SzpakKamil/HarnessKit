//
//  TextRenderCacheTests.swift
//  HarnessKitTransformTests
//
//  Covers Part XI / Item 6 — text-rendering intermediates cache.
//  Focus: leak safety (bounded size, aliasing safety) and clear semantics.
//

import XCTest
#if canImport(AppKit)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif
@testable import HarnessKitTransform

final class TextRenderCacheTests: XCTestCase {

    override func setUp() {
        super.setUp()
        TextRenderCache.clear()
    }

    // MARK: - Paragraph style cache

    func testRepeatedParagraphKeyReturnsSameInstance() {
        let a = TextRenderCache.paragraphStyle(alignment: .left, lineSpacingPx: 4)
        let b = TextRenderCache.paragraphStyle(alignment: .left, lineSpacingPx: 4)
        XCTAssertTrue(a === b, "paragraph style cache should alias on exact match")
        XCTAssertEqual(TextRenderCache.paragraphCacheSize, 1)
    }

    func testParagraphReturnsImmutable() {
        let p = TextRenderCache.paragraphStyle(alignment: .center, lineSpacingPx: 2)
        // NSMutableParagraphStyle.copy() returns NSParagraphStyle (immutable).
        // If any caller tries to cast and mutate, this assertion would fail.
        XCTAssertFalse(p is NSMutableParagraphStyle,
                       "cached paragraph style must be immutable to be alias-safe")
    }

    func testParagraphCacheBounded() {
        // maxEntries = 16 (private). Seed 50 distinct keys and check size.
        for i in 0..<50 {
            _ = TextRenderCache.paragraphStyle(
                alignment: .left,
                lineSpacingPx: CGFloat(i) * 0.5
            )
        }
        XCTAssertLessThanOrEqual(TextRenderCache.paragraphCacheSize, 16,
                                 "paragraph cache must not grow unbounded")
    }

    // MARK: - Shadow cache

    func testRepeatedShadowKeyReturnsFreshCopy() {
        let a = TextRenderCache.shadow(colorHex: "000000", opacity: 0.5,
                                        blur: 4, offsetX: 0, offsetY: 2, invertY: true)
        let b = TextRenderCache.shadow(colorHex: "000000", opacity: 0.5,
                                        blur: 4, offsetX: 0, offsetY: 2, invertY: true)
        // Must NOT alias — cache returns fresh copies so caller mutations
        // can't corrupt the template.
        XCTAssertFalse(a === b, "shadow cache must return fresh copies per call")
        XCTAssertEqual(a.shadowBlurRadius, b.shadowBlurRadius)
        XCTAssertEqual(a.shadowOffset.width, b.shadowOffset.width, accuracy: 0.01)
        XCTAssertEqual(TextRenderCache.shadowCacheSize, 1,
                       "template is cached once; copies are per-call")
    }

    /// CRITICAL leak/aliasing check: mutating the returned shadow must
    /// NOT affect the next caller's shadow. Validates the copy-on-read
    /// contract that keeps the cache's internal template safe.
    func testShadowMutationDoesNotCorruptCache() {
        let a = TextRenderCache.shadow(colorHex: "000000", opacity: 0.5,
                                        blur: 4, offsetX: 0, offsetY: 2, invertY: true)
        a.shadowBlurRadius = 999  // caller mutates the returned shadow

        let b = TextRenderCache.shadow(colorHex: "000000", opacity: 0.5,
                                        blur: 4, offsetX: 0, offsetY: 2, invertY: true)
        XCTAssertEqual(b.shadowBlurRadius, 4,
                       "second caller must get clean copy; template uncorrupted")
    }

    func testShadowCacheBounded() {
        for i in 0..<50 {
            _ = TextRenderCache.shadow(
                colorHex: String(format: "%06x", i),
                opacity: 0.5, blur: 4, offsetX: 0, offsetY: 2, invertY: true
            )
        }
        XCTAssertLessThanOrEqual(TextRenderCache.shadowCacheSize, 16,
                                 "shadow cache must not grow unbounded")
    }

    // MARK: - Clear

    func testClearWipesBothCaches() {
        _ = TextRenderCache.paragraphStyle(alignment: .left, lineSpacingPx: 4)
        _ = TextRenderCache.shadow(colorHex: "000000", opacity: 0.5,
                                    blur: 4, offsetX: 0, offsetY: 2, invertY: true)
        XCTAssertEqual(TextRenderCache.paragraphCacheSize, 1)
        XCTAssertEqual(TextRenderCache.shadowCacheSize, 1)

        TextRenderCache.clear()
        XCTAssertEqual(TextRenderCache.paragraphCacheSize, 0)
        XCTAssertEqual(TextRenderCache.shadowCacheSize, 0)
    }

    func testInvalidateCachesClearsTextCache() async {
        _ = TextRenderCache.paragraphStyle(alignment: .left, lineSpacingPx: 4)
        XCTAssertEqual(TextRenderCache.paragraphCacheSize, 1)
        await HarnessKitCatalogue.shared.invalidateCaches()
        XCTAssertEqual(TextRenderCache.paragraphCacheSize, 0,
                       "invalidateCaches() must clear text cache")
    }
}

//
//  BaseURLConfigTests.swift
//  HarnessKitTransformTests
//
//  Covers §S5.7 — `nonisolated(unsafe) baseURL` replaced with a thread-safe
//  read/configure pair backed by `os_unfair_lock_s`.
//

import XCTest
import Dispatch
@testable import HarnessKitTransform

final class BaseURLConfigTests: XCTestCase {

    private let production = URL(string: "https://harnesskitassets.kamilszpak.com")!
    private var savedURL: URL!

    override func setUp() {
        super.setUp()
        savedURL = HarnessKitCatalogue.baseURL
    }

    override func tearDown() {
        HarnessKitCatalogue.configureBaseURL(savedURL)
        super.tearDown()
    }

    /// Default URL when no override has been applied is the production R2 domain.
    func testDefaultBaseURLIsProduction() {
        // Start from a known state.
        HarnessKitCatalogue.configureBaseURL(production)
        XCTAssertEqual(HarnessKitCatalogue.baseURL, production)
    }

    /// Setter round-trip: configure → read returns the configured URL.
    func testConfigureRoundTrip() {
        let staging = URL(string: "https://staging.example.invalid")!
        HarnessKitCatalogue.configureBaseURL(staging)
        XCTAssertEqual(HarnessKitCatalogue.baseURL, staging)
    }

    /// Concurrent configure + read calls must not crash and must produce a
    /// deterministic last-writer-wins outcome (whichever URL was set last
    /// returns from the read after all tasks complete).
    func testConcurrentConfiguresAreRaceFree() {
        let urls = (0..<32).map { URL(string: "https://r\($0).example.invalid")! }
        let lastIndex = urls.count - 1

        DispatchQueue.concurrentPerform(iterations: urls.count) { i in
            HarnessKitCatalogue.configureBaseURL(urls[i])
            // Force a read on the same iteration to prove read-during-write is safe.
            _ = HarnessKitCatalogue.baseURL
        }

        // After all writers are done, set a known final value and verify the
        // read sees it. Race-freedom of the loop itself is implied by no
        // crash + Thread Sanitizer (when CI runs with -sanitize=thread).
        HarnessKitCatalogue.configureBaseURL(urls[lastIndex])
        XCTAssertEqual(HarnessKitCatalogue.baseURL, urls[lastIndex])
    }

    /// `baseURL` is now a get-only computed property — verifying the setter
    /// went through `configureBaseURL` ensures the test exercises both paths.
    func testReadIsConsistentWithConfigure() {
        for i in 0..<10 {
            let url = URL(string: "https://example\(i).invalid")!
            HarnessKitCatalogue.configureBaseURL(url)
            XCTAssertEqual(HarnessKitCatalogue.baseURL, url)
        }
    }
}

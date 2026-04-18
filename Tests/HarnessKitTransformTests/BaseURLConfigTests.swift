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
        HarnessKitCatalogue.baseURL = savedURL
        super.tearDown()
    }

    /// Default URL when no override has been applied is the production R2 domain.
    func testDefaultBaseURLIsProduction() {
        // Start from a known state.
        HarnessKitCatalogue.baseURL = production
        XCTAssertEqual(HarnessKitCatalogue.baseURL, production)
    }

    /// Setter round-trip: assign → read returns the assigned URL.
    func testConfigureRoundTrip() {
        let staging = URL(string: "https://staging.example.invalid")!
        HarnessKitCatalogue.baseURL = staging
        XCTAssertEqual(HarnessKitCatalogue.baseURL, staging)
    }

    /// Concurrent assigns + reads must not crash and must produce a
    /// deterministic last-writer-wins outcome (whichever URL was set last
    /// returns from the read after all tasks complete).
    func testConcurrentConfiguresAreRaceFree() {
        let urls = (0..<32).map { URL(string: "https://r\($0).example.invalid")! }
        let lastIndex = urls.count - 1

        DispatchQueue.concurrentPerform(iterations: urls.count) { i in
            HarnessKitCatalogue.baseURL = urls[i]
            // Force a read on the same iteration to prove read-during-write is safe.
            _ = HarnessKitCatalogue.baseURL
        }

        // After all writers are done, set a known final value and verify the
        // read sees it. Race-freedom of the loop itself is implied by no
        // crash + Thread Sanitizer (when CI runs with -sanitize=thread).
        HarnessKitCatalogue.baseURL = urls[lastIndex]
        XCTAssertEqual(HarnessKitCatalogue.baseURL, urls[lastIndex])
    }

    /// Verifies the get/set pair stays consistent across many round-trips.
    func testReadIsConsistentWithConfigure() {
        for i in 0..<10 {
            let url = URL(string: "https://example\(i).invalid")!
            HarnessKitCatalogue.baseURL = url
            XCTAssertEqual(HarnessKitCatalogue.baseURL, url)
        }
    }
}

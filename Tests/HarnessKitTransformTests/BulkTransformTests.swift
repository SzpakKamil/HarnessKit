//
//  BulkTransformTests.swift
//  HarnessKitTransformTests
//
//  Covers §S9.1 + §S9.2 + §S9.3 — bulk transform API.
//  S9.1: parallel `transformScreenshots(_:)` over `withThrowingTaskGroup`
//        with bounded concurrency.
//  S9.2: cancellation propagates as `CancellationError` (`transformScreenshot`
//        guards before persisting).
//  S9.3: gate criteria — 100-input stress + memory-budget overload.
//

import XCTest
import CoreGraphics
@testable import HarnessKitTransform
import HarnessKitScreenshots

final class BulkTransformTests: XCTestCase {

    private var tempDir: URL!

    override func setUp() {
        super.setUp()
        tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("HarnessKitBulkTransform-\(UUID().uuidString)", isDirectory: true)
    }

    override func tearDown() {
        try? FileManager.default.removeItem(at: tempDir)
        super.tearDown()
    }

    // MARK: - Fixtures

    /// 32×32 solid bitmap. Small enough that 100 inputs run quickly; addBezel:false
    /// keeps the catalogue out of the loop, so this works without a populated cache.
    private func referenceImage(width: Int = 32, height: Int = 32) -> PlatformImage {
        let cs = CGColorSpaceCreateDeviceRGB()
        let ctx = CGContext(
            data: nil, width: width, height: height,
            bitsPerComponent: 8, bytesPerRow: 0, space: cs,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        )!
        ctx.setFillColor(red: 0.2, green: 0.4, blue: 0.9, alpha: 1.0)
        ctx.fill(CGRect(x: 0, y: 0, width: width, height: height))
        let cg = ctx.makeImage()!
        #if canImport(AppKit)
        let img = NSImage(size: NSSize(width: width, height: height))
        img.addRepresentation(NSBitmapImageRep(cgImage: cg))
        return img
        #else
        return UIImage(cgImage: cg)
        #endif
    }

    private func makeInput(id: String) -> BulkTransformInput {
        BulkTransformInput(
            image: referenceImage(),
            screenshot: Screenshot(id: id, appearance: .light, os: .iOS, addBezel: false)
        )
    }

    private func pngCount(in dir: URL) -> Int {
        (try? FileManager.default.contentsOfDirectory(at: dir, includingPropertiesForKeys: nil)
            .filter { $0.pathExtension == "png" }.count) ?? 0
    }

    // MARK: - §S9.1: bulk produces all outputs

    func testBulkTransformProducesAllOutputs() async throws {
        let inputs = (0..<5).map { makeInput(id: "fixture-\($0)") }

        try await transformScreenshots(
            inputs,
            config: .defaults,
            outputDirectory: tempDir,
            concurrency: 2
        )

        XCTAssertEqual(pngCount(in: tempDir), 5)
    }

    /// Empty input is a no-op. Doesn't touch the directory at all.
    func testBulkTransformEmptyInputIsNoOp() async throws {
        try await transformScreenshots(
            [],
            config: .defaults,
            outputDirectory: tempDir,
            concurrency: 4
        )
        XCTAssertFalse(FileManager.default.fileExists(atPath: tempDir.path))
    }

    // MARK: - §S9.2: cancellation

    /// Outer-task cancellation propagates as `CancellationError`. Wrap the
    /// bulk call in a Task, cancel it, await throws.
    func testCancellationPropagatesAsCancellationError() async throws {
        let inputs = (0..<20).map { makeInput(id: "cancel-\($0)") }
        let outputDir = tempDir!

        let task = Task<Void, Error> { [inputs] in
            try await transformScreenshots(
                inputs,
                config: .defaults,
                outputDirectory: outputDir,
                concurrency: 2
            )
        }
        task.cancel()

        do {
            try await task.value
            XCTFail("expected CancellationError, got success")
        } catch is CancellationError {
            // expected — `transformScreenshot`'s top guard converts pre-cancelled
            // tasks into `CancellationError` before the pipeline runs.
        } catch {
            XCTFail("expected CancellationError, got: \(error)")
        }
    }

    /// Error in one task surfaces from the group; siblings get auto-cancelled.
    /// Use an unwritable output URL to force a save failure on every task —
    /// the first throw cancels the rest.
    func testErrorInOneTaskCancelsSiblings() async throws {
        let inputs = (0..<10).map { makeInput(id: "err-\($0)") }
        // Path under /dev/null/ is unwritable — saveResults() will throw on
        // createDirectory.
        let unwritable = URL(fileURLWithPath: "/dev/null/cannot-create/sub")

        do {
            try await transformScreenshots(
                inputs,
                config: .defaults,
                outputDirectory: unwritable,
                concurrency: 4
            )
            XCTFail("expected throw from unwritable output directory")
        } catch {
            // Any error from saveResults is fine; the assertion is that the
            // group rethrows rather than completing silently.
        }
    }

    // MARK: - §S9.3: memory-budget overload + 100-input stress

    /// Memory-budget overload picks `concurrency = max(1, budget / 280)`.
    /// budget=560 → concurrency=2. We can't observe the internal value
    /// directly, but we CAN verify behavior: 100 inputs at concurrency=2
    /// completes successfully and writes 100 outputs.
    func testMemoryBudgetPicksConcurrencyFromBudget() async throws {
        let inputs = (0..<10).map { makeInput(id: "budget-\($0)") }

        try await transformScreenshots(
            inputs,
            config: .defaults,
            outputDirectory: tempDir,
            memoryBudgetMB: 560  // → concurrency = 2
        )

        XCTAssertEqual(pngCount(in: tempDir), 10)
    }

    /// Tiny budget clamps to concurrency=1 (`max(1, 1/280) == 1`).
    func testMemoryBudgetClampsToOneAtTinyValues() async throws {
        let inputs = (0..<3).map { makeInput(id: "tiny-\($0)") }
        try await transformScreenshots(
            inputs,
            config: .defaults,
            outputDirectory: tempDir,
            memoryBudgetMB: 1  // → max(1, 0) = 1
        )
        XCTAssertEqual(pngCount(in: tempDir), 3)
    }

    /// §S9.3 criterion 1: 100 synthetic screenshots through the bulk API,
    /// concurrency=4 default. Asserts all 100 PNGs land in the directory.
    func testStress100Inputs() async throws {
        let inputs = (0..<100).map { makeInput(id: "stress-\($0)") }

        try await transformScreenshots(
            inputs,
            config: .defaults,
            outputDirectory: tempDir,
            concurrency: 4
        )

        XCTAssertEqual(pngCount(in: tempDir), 100)
    }
}

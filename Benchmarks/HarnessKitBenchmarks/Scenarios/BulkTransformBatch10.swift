//
//  BulkTransformBatch10.swift
//  HarnessKitBenchmarks
//
//  §S9.3 witness — sequential vs bulk pair to measure the speedup of
//  `transformScreenshots(_:)` over a hand-rolled for-loop.
//
//  Both scenarios run the same 10 inputs (`Screenshot(addBezel: false)`,
//  iPhone target, 1290×2796 synthetic gradient) through the public
//  `transformScreenshot` entrypoint and write PNGs to a per-iteration
//  temporary directory. The Bulk variant uses `withThrowingTaskGroup`
//  bounded at `activeProcessorCount`; the Sequential variant calls
//  `transformScreenshot` 10× back-to-back from a single task.
//
//  The plan's headline target is ~2.5× wall-time speedup on an 8-core
//  Mac. Memory comparison shows steady-state RSS bounded by
//  `concurrency × per-task` for the bulk path.
//

import Foundation
import CoreGraphics
import HarnessKitScreenshots
import HarnessKitTransform

private func makeBatchInputs(count: Int) -> [TransformJob] {
    let image = SyntheticImage.gradient(width: 1290, height: 2796)
    return (0..<count).map { i in
        TransformJob(
            image: image,
            screenshot: Screenshot(
                id: "bulk-\(i)",
                appearance: .light,
                os: .iOS,
                addBezel: false
            )
        )
    }
}

/// Sequential baseline: call `transformScreenshot` 10× in a row from one task.
final class BulkTransformBatch10Sequential: Scenario, @unchecked Sendable {
    let name = "BulkTransformBatch10-Sequential"
    let iterations = 1
    var usesAsync: Bool { true }

    private var inputs: [TransformJob]!
    private var outputDir: URL!

    func prepare() throws {
        inputs = makeBatchInputs(count: 10)
        outputDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("HarnessKitBulkBench-Seq-\(UUID().uuidString)", isDirectory: true)
    }

    func run() throws -> PlatformImage? { nil }

    func runAsync() async throws -> PlatformImage? {
        for input in inputs {
            try Transformer.transform(input.screenshot, image: input.image, config: .defaults, into: outputDir
            )
        }
        return nil
    }

    func teardown() {
        try? FileManager.default.removeItem(at: outputDir)
        inputs = nil
        outputDir = nil
    }
}

/// Bulk path: same 10 inputs through `transformScreenshots(_:)` with
/// `concurrency = ProcessInfo.processInfo.activeProcessorCount`.
final class BulkTransformBatch10Bulk: Scenario, @unchecked Sendable {
    let name = "BulkTransformBatch10-Bulk"
    let iterations = 1
    var usesAsync: Bool { true }

    private var inputs: [TransformJob]!
    private var outputDir: URL!

    func prepare() throws {
        inputs = makeBatchInputs(count: 10)
        outputDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("HarnessKitBulkBench-Bulk-\(UUID().uuidString)", isDirectory: true)
    }

    func run() throws -> PlatformImage? { nil }

    func runAsync() async throws -> PlatformImage? {
        try await Transformer.transform(inputs, config: .defaults, into: outputDir
        )
        return nil
    }

    func teardown() {
        try? FileManager.default.removeItem(at: outputDir)
        inputs = nil
        outputDir = nil
    }
}

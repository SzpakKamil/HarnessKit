//
//  Scenario.swift
//  HarnessKitBenchmarks
//

import Foundation
import AppKit
import HarnessKitTransform

/// A single benchmark unit. `prepare` sets up inputs once (not timed); `run`
/// is the hot path the driver times and samples memory across; `teardown`
/// releases anything that would pollute the next scenario's baseline.
///
/// Conforming types hold mutable state between `prepare` and `run`; the
/// driver uses scenarios sequentially on a single task, so `@unchecked
/// Sendable` is the right escape hatch for stored `NSImage` / `UUID` slots.
///
/// `run()` must return the produced image (or nil). The driver forces
/// rasterization before measuring the next iteration — `NSImage`'s drawing
/// closure is lazy, so without an explicit materialization step the numbers
/// only reflect graph construction, not pixel work.
protocol Scenario: AnyObject, Sendable {
    var name: String { get }
    /// Number of times `run()` is invoked per measurement. Higher iteration
    /// counts smooth out noise on fast scenarios.
    var iterations: Int { get }
    /// Set to `true` for scenarios whose hot path is genuinely async (e.g.
    /// the bulk transform API). Driver routes them through `runAsync()`
    /// instead of `run()`. Sync scenarios stay on the legacy timing path
    /// so memory baselines compare apples-to-apples.
    var usesAsync: Bool { get }
    func prepare() throws
    func run() throws -> PlatformImage?
    /// Async-capable hot path. Default impl forwards to the sync `run()`;
    /// scenarios that genuinely need `await` (e.g. the bulk transform API)
    /// override this and set `usesAsync = true`.
    func runAsync() async throws -> PlatformImage?
    func teardown()
}

extension Scenario {
    var iterations: Int { 1 }
    var usesAsync: Bool { false }
    func prepare() throws {}
    func runAsync() async throws -> PlatformImage? { try run() }
    func teardown() {}
}

/// Forces the draw closure inside an `NSImage` to execute and its bitmap to
/// be backed. Benchmarks call this from the driver after each `run()` so the
/// measurement captures real rendering cost, not deferred graph construction.
@inline(never)
func forceMaterialize(_ image: PlatformImage?) {
    guard let image else { return }
    // `cgImage(forProposedRect:)` on NSImage locks in the bitmap behind the
    // drawing closure; mutating `proposedRect` to a non-zero size gives the
    // system the dimensions it needs to pick a representation.
    var rect = NSRect(origin: .zero, size: image.size)
    _ = image.cgImage(forProposedRect: &rect, context: nil, hints: nil)
}

/// One measurement result emitted as a CSV row.
struct Measurement {
    let name: String
    let iterations: Int
    let elapsedSeconds: Double
    let peakDeltaBytes: Int64

    var csvRow: String {
        let elapsedMs = elapsedSeconds * 1000.0
        let peakMB = Double(peakDeltaBytes) / (1024.0 * 1024.0)
        return String(format: "%@,%d,%.3f,%.2f", name, iterations, elapsedMs, peakMB)
    }

    static var csvHeader: String {
        "scenario,iterations,elapsedMs,peakDeltaMB"
    }
}

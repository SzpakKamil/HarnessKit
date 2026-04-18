// Bulk `transformScreenshots(_:)` API. Processes many screenshots in
// parallel via `withThrowingTaskGroup`, bounded by `concurrency` so
// peak RAM stays at `concurrency × per-task` instead of `inputs.count ×
// per-task`. Each task wraps in `autoreleasepool` so per-task allocations
// drain immediately on completion.

import Foundation
import HarnessKitScreenshots

/// Processes `inputs` in parallel and writes one PNG per input to
/// `outputDirectory`. Throttled to at most `concurrency` in-flight tasks.
///
/// Errors propagate via structured concurrency: when one task throws, the
/// task group auto-cancels its siblings and waits for them before
/// rethrowing — partially-written outputs from already-completed siblings
/// remain on disk; in-flight tasks bail at their next `Task.isCancelled`
/// checkpoint inside the synchronous `transformScreenshot` body.
///
/// Outer-task cancellation propagates the same way: cancelling the `Task`
/// that hosts this call cascades down to every in-flight task, which see
/// `Task.isCancelled` at the next pipeline checkpoint and at the
/// `try Task.checkCancellation()` guard inside `transformScreenshot`.
///
/// - Parameters:
///   - inputs: Screenshots to transform. Empty input is a no-op.
///   - config: Shared `ScreenshotConfig`. Captured into each task closure.
///   - outputDirectory: Each task writes one PNG into this directory using
///     `screenshot.prettyName() + ".png"`.
///   - concurrency: Maximum number of in-flight tasks. Defaults to
///     `ProcessInfo.processInfo.activeProcessorCount` and is clamped to
///     `[1, inputs.count]`.
public func transformScreenshots(
    _ inputs: [BulkTransformInput],
    config: ScreenshotConfig,
    outputDirectory: URL,
    concurrency: Int = ProcessInfo.processInfo.activeProcessorCount
) async throws {
    guard !inputs.isEmpty else { return }
    let bounded = max(1, min(concurrency, inputs.count))
    var iterator = inputs.makeIterator()

    try await withThrowingTaskGroup(of: Void.self) { group in
        // Seed: kick off `bounded` tasks so the throttle invariant is
        // structural — only `bounded` tasks ever exist concurrently. No
        // per-iteration counter needed.
        for _ in 0..<bounded {
            guard let input = iterator.next() else { break }
            group.addTask {
                try autoreleasepool {
                    try transformScreenshot(
                        image: input.image,
                        screenshot: input.screenshot,
                        config: config,
                        outputDirectory: outputDirectory
                    )
                }
            }
        }
        // Drain: consume one completion, add one task. The group's
        // self-cancellation on throw propagates here — `group.next()`
        // rethrows the first failure and the body returns; subsequent
        // siblings are auto-cancelled and awaited by the group's own
        // teardown.
        while try await group.next() != nil {
            guard let input = iterator.next() else { continue }
            group.addTask {
                try autoreleasepool {
                    try transformScreenshot(
                        image: input.image,
                        screenshot: input.screenshot,
                        config: config,
                        outputDirectory: outputDirectory
                    )
                }
            }
        }
    }
}

/// Convenience overload that derives `concurrency` from a memory budget.
/// Picks `max(1, memoryBudgetMB / perTaskMB)` where `perTaskMB = 280`
/// (post-Part-V steady-state estimate for a 4K-canvas, single-bezel
/// transform). Use this when you want bounded peak RSS regardless of
/// core count — e.g. a CI runner with 8 cores and 1 GB free.
public func transformScreenshots(
    _ inputs: [BulkTransformInput],
    config: ScreenshotConfig,
    outputDirectory: URL,
    memoryBudgetMB: Int
) async throws {
    let perTaskMB = 280
    let concurrency = max(1, memoryBudgetMB / perTaskMB)
    try await transformScreenshots(
        inputs,
        config: config,
        outputDirectory: outputDirectory,
        concurrency: concurrency
    )
}

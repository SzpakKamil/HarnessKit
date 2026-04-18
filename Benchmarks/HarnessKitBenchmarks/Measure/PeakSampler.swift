//
//  PeakSampler.swift
//  HarnessKitBenchmarks
//
//  Polls MemoryProbe.residentBytes() at a fixed interval on a background
//  task and records the high-water mark across the sampling window.
//

import Foundation

actor PeakSampler {
    private var peak: Int64 = 0
    private var baseline: Int64 = 0
    private var running = false
    private var pollTask: Task<Void, Never>?

    /// Starts sampling. Records the current RSS as the baseline; peak is
    /// reported as `peak - baseline` in `stop()`.
    func start(intervalNanoseconds: UInt64 = 5_000_000) {  // 5 ms ≈ 200 Hz
        guard !running else { return }
        running = true
        baseline = MemoryProbe.residentBytes()
        peak = baseline
        pollTask = Task.detached(priority: .userInitiated) { [weak self] in
            while await self?.running == true {
                if let now = await self?.sampleOnce() {
                    _ = now
                }
                try? await Task.sleep(nanoseconds: intervalNanoseconds)
            }
        }
    }

    /// Stops sampling and returns the peak delta above the baseline recorded at `start`.
    func stop() async -> Int64 {
        running = false
        pollTask?.cancel()
        _ = await pollTask?.value
        pollTask = nil
        // One final read in case the scenario finished just before we polled.
        let final = MemoryProbe.residentBytes()
        if final > peak { peak = final }
        return max(0, peak - baseline)
    }

    private func sampleOnce() -> Int64 {
        let r = MemoryProbe.residentBytes()
        if r > peak { peak = r }
        return r
    }
}

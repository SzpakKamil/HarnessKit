//
//  Driver.swift
//  HarnessKitBenchmarks
//

import Foundation

struct Driver {
    let scenarios: [Scenario]

    func run() async throws -> [Measurement] {
        var results: [Measurement] = []
        for scenario in scenarios {
            FileHandle.standardError.write(Data("running: \(scenario.name)\n".utf8))
            try scenario.prepare()

            // Let the previous scenario's autoreleased state drain before we
            // sample a baseline — otherwise peakDelta includes noise from the
            // prior run.
            autoreleasepool {}
            try await Task.sleep(nanoseconds: 50_000_000)  // 50 ms settle

            let sampler = PeakSampler()
            await sampler.start()

            let clock = BenchClock()
            // Async scenarios (e.g. bulk transform) need their own timing
            // path because `await` can't live inside a sync autoreleasepool.
            // Sync scenarios stay on the legacy path so memory baselines
            // remain bit-identical to pre-S9.1 measurements.
            let elapsedSeconds: Double
            if scenario.usesAsync {
                (_, elapsedSeconds) = try await clock.measureAsync {
                    for _ in 0..<scenario.iterations {
                        let result = try await scenario.runAsync()
                        autoreleasepool { forceMaterialize(result) }
                    }
                }
            } else {
                (_, elapsedSeconds) = try clock.measure {
                    for _ in 0..<scenario.iterations {
                        try autoreleasepool {
                            let result = try scenario.run()
                            forceMaterialize(result)
                        }
                    }
                }
            }

            let peak = await sampler.stop()
            scenario.teardown()

            results.append(Measurement(
                name: scenario.name,
                iterations: scenario.iterations,
                elapsedSeconds: elapsedSeconds,
                peakDeltaBytes: peak
            ))
        }
        return results
    }
}

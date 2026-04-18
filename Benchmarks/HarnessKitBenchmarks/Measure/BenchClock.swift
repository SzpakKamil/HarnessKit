//
//  BenchClock.swift
//  HarnessKitBenchmarks
//
//  Plain mach-absolute-time-based wall clock. `ContinuousClock.Duration.components`
//  is macOS 13+; benchmarks should compile at the package's declared floor.
//

import Foundation

struct BenchClock {
    func measure<T>(_ body: () throws -> T) rethrows -> (result: T, elapsedSeconds: Double) {
        let start = Date()
        let value = try body()
        let elapsed = Date().timeIntervalSince(start)
        return (value, elapsed)
    }

    func measureAsync<T>(_ body: () async throws -> T) async rethrows -> (result: T, elapsedSeconds: Double) {
        let start = Date()
        let value = try await body()
        let elapsed = Date().timeIntervalSince(start)
        return (value, elapsed)
    }
}

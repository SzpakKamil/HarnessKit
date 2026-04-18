//
//  Compare.swift
//  HarnessKitBenchmarks
//
//  Cross-references a freshly measured scenario list against a committed
//  baseline CSV and reports per-scenario deltas. Intended for local "did my
//  change regress anything?" checks and, later, for CI gating once each
//  runner has a committed baseline of its own.
//
//  Baseline CSV format matches `Measurement.csvHeader`:
//      scenario,iterations,elapsedMs,peakDeltaMB
//

import Foundation

struct CompareOptions: Sendable {
    /// Fractional regression beyond which `evaluate` returns a failure for
    /// `peakDeltaMB`. 0.05 ⇒ 5% worse peak RSS is the failure line.
    var memoryThreshold: Double = 0.05
    /// Fractional regression beyond which `evaluate` returns a failure for
    /// `elapsedMs`. 0.10 ⇒ 10% worse wall time is the failure line.
    var timeThreshold: Double = 0.10
    /// When true, missing baseline rows are treated as an error. When
    /// false, they're reported but don't cause a failure — useful before
    /// CI has captured its first baseline.
    var strictMissingBaseline: Bool = false
}

enum Compare {
    /// Returns `true` if no scenario regressed past the thresholds.
    /// Always prints a markdown-ish report to stdout.
    static func evaluate(
        current: [Measurement],
        baseline: [Measurement],
        options: CompareOptions
    ) -> Bool {
        let baselineByName = Dictionary(uniqueKeysWithValues: baseline.map { ($0.name, $0) })

        print("")
        print("| scenario | baseline ms | now ms | Δ% | baseline MB | now MB | Δ% | verdict |")
        print("|---|---:|---:|---:|---:|---:|---:|:---:|")

        var anyFailure = false
        for m in current {
            guard let base = baselineByName[m.name] else {
                print("| \(m.name) | _missing_ | \(fmtMs(m.elapsedSeconds)) | — | _missing_ | \(fmtMB(m.peakDeltaBytes)) | — | \(options.strictMissingBaseline ? "❌" : "➖") |")
                if options.strictMissingBaseline { anyFailure = true }
                continue
            }

            let timeRatio = ratio(current: m.elapsedSeconds, baseline: base.elapsedSeconds)
            let memRatio = ratio(current: Double(m.peakDeltaBytes), baseline: Double(base.peakDeltaBytes))

            let timeRegressed = timeRatio > options.timeThreshold
            let memRegressed  = memRatio  > options.memoryThreshold
            let failed = timeRegressed || memRegressed
            if failed { anyFailure = true }

            print("""
            | \(m.name) | \(fmtMs(base.elapsedSeconds)) | \(fmtMs(m.elapsedSeconds)) | \(fmtPct(timeRatio)) | \(fmtMB(base.peakDeltaBytes)) | \(fmtMB(m.peakDeltaBytes)) | \(fmtPct(memRatio)) | \(failed ? "❌" : "✅") |
            """)
        }

        print("")
        if anyFailure {
            print("❌ regression detected (threshold: mem \(Int(options.memoryThreshold * 100))%, time \(Int(options.timeThreshold * 100))%)")
        } else {
            print("✅ all scenarios within thresholds")
        }
        return !anyFailure
    }

    /// Parses a CSV produced by the benchmark driver. Ignores the header
    /// row; rejects malformed rows silently (failing open is fine — the
    /// comparison will then report them as missing).
    static func readCSV(at url: URL) throws -> [Measurement] {
        let raw = try String(contentsOf: url, encoding: .utf8)
        var result: [Measurement] = []
        for line in raw.split(whereSeparator: { $0.isNewline }) {
            let fields = line.split(separator: ",", omittingEmptySubsequences: false).map(String.init)
            guard fields.count == 4 else { continue }
            if fields[0] == "scenario" { continue }  // header
            guard let iterations = Int(fields[1]),
                  let elapsedMs = Double(fields[2]),
                  let peakMB = Double(fields[3]) else { continue }
            result.append(Measurement(
                name: fields[0],
                iterations: iterations,
                elapsedSeconds: elapsedMs / 1000.0,
                peakDeltaBytes: Int64(peakMB * 1024 * 1024)
            ))
        }
        return result
    }

    // MARK: - Formatting

    private static func ratio(current: Double, baseline: Double) -> Double {
        guard baseline > 0 else { return 0 }
        return (current - baseline) / baseline
    }
    private static func fmtMs(_ seconds: Double) -> String {
        String(format: "%.1f", seconds * 1000.0)
    }
    private static func fmtMB(_ bytes: Int64) -> String {
        String(format: "%.1f", Double(bytes) / (1024.0 * 1024.0))
    }
    private static func fmtPct(_ ratio: Double) -> String {
        // Positive = regression; negative = improvement.
        let sign = ratio >= 0 ? "+" : ""
        return String(format: "%@%.1f%%", sign, ratio * 100.0)
    }
}

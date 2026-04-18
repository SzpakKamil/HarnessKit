//
//  main.swift
//  HarnessKitBenchmarks
//
//  Prints one CSV row per scenario to stdout; diagnostics + compare tables
//  go to stderr.
//
//  Usage:
//      swift run -c release HarnessKitBenchmarks
//      swift run -c release HarnessKitBenchmarks --only CanvasShadowStress-4K-3groups
//      swift run -c release HarnessKitBenchmarks --compare Benchmarks/baselines/1.0-baseline.csv
//      swift run -c release HarnessKitBenchmarks --compare <baseline> --strict
//

import Foundation

struct CLIArgs {
    var onlyFilter: String?
    var comparePath: String?
    /// Without --strict, missing-baseline rows are reported but do not
    /// cause a non-zero exit — lets CI start green before every runner
    /// has a committed baseline.
    var strict: Bool = false
    /// Fractional regression threshold overrides.
    var memoryThreshold: Double = 0.05
    var timeThreshold: Double = 0.10
}

func parseArgs() -> CLIArgs {
    var result = CLIArgs()
    let args = CommandLine.arguments
    var i = 1
    while i < args.count {
        let arg = args[i]
        switch arg {
        case "--only":
            if i + 1 < args.count { result.onlyFilter = args[i + 1]; i += 1 }
        case "--compare":
            if i + 1 < args.count { result.comparePath = args[i + 1]; i += 1 }
        case "--strict":
            result.strict = true
        case "--mem-threshold":
            if i + 1 < args.count, let v = Double(args[i + 1]) { result.memoryThreshold = v; i += 1 }
        case "--time-threshold":
            if i + 1 < args.count, let v = Double(args[i + 1]) { result.timeThreshold = v; i += 1 }
        default:
            FileHandle.standardError.write(Data("unknown arg: \(arg)\n".utf8))
        }
        i += 1
    }
    return result
}

let cli = parseArgs()

let allScenarios: [Scenario] = [
    CanvasBackgroundOnly(),
    ApplyShadowsStress(),
    CanvasShadowStress(),
    CanvasEffectsStress(),
    CanvasLayerChain(),
    NoBezelPipelineStress(),
    NoBezelPipelineStressLandscape(),
    NoBezelPipelineStressLandscapeUnopt(),
    BezelPipelineStressLandscape(),
    BezelPipelineStressLandscapeUnopt(),
    CropImageStress(),
    CropImageStressUnopt(),
    ManifestPrefixScan(),
    ManifestPrefixScanUnopt(),
    BezelResolutionStress(),
    MatchedBezelStress(),
    BulkTransformBatch10Sequential(),
    BulkTransformBatch10Bulk(),
]

let filtered: [Scenario] = {
    if let name = cli.onlyFilter {
        return allScenarios.filter { $0.name == name }
    }
    return allScenarios
}()

guard !filtered.isEmpty else {
    FileHandle.standardError.write(Data("no matching scenarios\n".utf8))
    exit(1)
}

print(Measurement.csvHeader)

let results: [Measurement]
do {
    let driver = Driver(scenarios: filtered)
    results = try await driver.run()
    for m in results {
        print(m.csvRow)
    }
} catch {
    FileHandle.standardError.write(Data("error: \(error)\n".utf8))
    exit(2)
}

// Compare step: only runs when --compare is given. Output goes to stderr so
// the stdout CSV stays clean for piping/redirection.
if let comparePath = cli.comparePath {
    let baselineURL = URL(fileURLWithPath: comparePath)
    do {
        let baseline = try Compare.readCSV(at: baselineURL)
        let stderr = FileHandle.standardError
        stderr.write(Data("\n--- compare against \(comparePath) ---\n".utf8))
        // Rebind print() to stderr so the report doesn't corrupt the CSV.
        let saved = freopen("/dev/stderr", "w", stdout)
        defer { if saved != nil { _ = freopen("/dev/stdout", "w", stdout) } }

        let opts = CompareOptions(
            memoryThreshold: cli.memoryThreshold,
            timeThreshold: cli.timeThreshold,
            strictMissingBaseline: cli.strict
        )
        let ok = Compare.evaluate(current: results, baseline: baseline, options: opts)
        if !ok && cli.strict {
            exit(3)
        }
    } catch {
        FileHandle.standardError.write(Data("compare failed to read \(comparePath): \(error)\n".utf8))
        if cli.strict { exit(4) }
    }
}

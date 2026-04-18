# HarnessKit Benchmarks

Baseline measurement harness for the HarnessKit optimization plan. Every
subsequent memory/perf PR diffs against the CSV committed here.

## Run

```sh
swift run -c release HarnessKitBenchmarks > /tmp/run.csv
diff baselines/1.0-baseline.csv /tmp/run.csv
```

Run a single scenario:

```sh
swift run -c release HarnessKitBenchmarks --only CanvasShadowStress-4K-3groups
```

## Output

Columns: `scenario,iterations,elapsedMs,peakDeltaMB`

- `iterations` — times `run()` was invoked per measurement (scenarios with
  sub-ms run time use >1 to smooth noise).
- `elapsedMs` — wall clock across all iterations (not per-iter).
- `peakDeltaMB` — high-water resident-set growth above the baseline
  recorded right before `run()` started. Best-effort sample (~200 Hz).

## Scenarios

| Name | Purpose |
|---|---|
| `CanvasBackgroundOnly-4K` | Floor cost: canvas + background, no layers. |
| `ApplyShadowsStress-4K-3groups` | Non-canvas `applyShadows` with 3 blur-radius groups — witness for §S3.2 shadow rewrite. |
| `CanvasShadowStress-4K-3groups` | Canvas `renderContactShadows` with 3 blur-radius groups. Same rewrite target. |
| `CanvasEffectsStress-4K-4effects` | 4-effect chain in `applyCanvasEffects` — witness for §S3.1 CIFilter fusion. |
| `CanvasLayerChain-4K-6layers` | Multi-layer composition with corner-radius + backgroundColor layers — §S3.5 witness. |
| `NoBezelPipelineStress-iPhone-4K` | Full no-bezel pipeline — witness for §S2.2 autoreleasepool + §S4.* pipeline fixes. |

## Caveats

- Bezel-resolution scenarios are intentionally omitted until an offline
  bundled bezel is available (current package ships only JSON catalogues).
- `peakDeltaMB` is a sampled approximation — treat < 5 MB differences as
  noise. Run-to-run variance on the same scenario is typically 5–15% for
  peak MB; the compare thresholds (5% mem, 10% time) are intentionally
  loose to avoid flakiness.
- For tight measurement use Xcode Instruments
  (`Benchmarks/HarnessKitBenchmarks.tracetemplate`, coming with §S1.4).

## Compare

```sh
swift run -c release HarnessKitBenchmarks \
    --compare baselines/1.0-baseline.csv
```

Prints a markdown table with Δ% per scenario. Without `--strict`, exit
code is always 0 — useful for CI before a runner-specific baseline is
captured. With `--strict`, exits non-zero (`3`) on regression past
thresholds.

Tune thresholds: `--mem-threshold 0.05 --time-threshold 0.10` (defaults
shown).

## Profiling in Instruments

`profile.sh` wraps `xcrun xctrace record` to drop a `.trace` file in
`.bench-out/` and open it in Instruments.app. No fragile
`.tracetemplate` binary checked into the repo — Apple's format is Xcode-
version-dependent, so we use the built-in standard templates instead.

```sh
Benchmarks/profile.sh                                  # Allocations, all scenarios
Benchmarks/profile.sh time                             # Time Profiler
Benchmarks/profile.sh leaks                            # Leaks
Benchmarks/profile.sh concurrency                      # Swift Concurrency
Benchmarks/profile.sh alloc CanvasShadowStress-4K-3groups   # scenario filter
```

Recommended initial workflow when investigating a new allocation hotspot:

1. `Benchmarks/profile.sh alloc <scenario>` — record an Allocations
   trace.
2. In Instruments, switch to the **Call Tree** mode on the Allocations
   track, group by **Inverted Call Tree**, and search for
   `renderCanvas` or `applyBezelPipeline`. The call trees rooted there
   show where your memory is going.
3. For CPU hot-spots, re-run with `Benchmarks/profile.sh time <scenario>`
   and sort the Call Tree by Weight.

Template shortcuts → Apple template mappings:

| Shortcut | Template |
|---|---|
| `alloc` / `allocations` | Allocations |
| `time` / `profile`      | Time Profiler |
| `leaks`                 | Leaks |
| `concurrency`           | Swift Concurrency |
| `system`                | System Trace |

Traces land in `.bench-out/` (gitignored via the project `.gitignore`;
add the path if you have a clean-tree policy).

## CI integration

`.github/workflows/swift.yml` has two jobs:

- `snapshot-goldens` — runs `swift test --filter GoldenTests`. Strict
  gate; any pixel diff fails CI.
- `benchmarks` — builds + runs `HarnessKitBenchmarks --compare
  baselines/1.0-baseline.csv`. Non-strict today (exit 0 even on
  regression). Uploads `current.csv` as an artifact for manual review.
  Flip `--strict` on after committing a CI-specific baseline under
  `baselines/ci-macos-15.csv`.

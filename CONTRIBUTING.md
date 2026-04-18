# Contributing to HarnessKit

Local conventions and invariants you need to know before editing the package.

## Underscore prefix means "locked backing storage"

A name with a leading `_` is **locked backing storage that callers must never
touch directly**. Reads and writes happen through a lock-acquiring computed
property, method, or actor on the same type — never through the underscored
name from outside that type's lock-coordination boundary.

Private helpers without lock coordination **drop the underscore**.

```swift
final class ObjectCache: @unchecked Sendable {
    private let _lock = os_unfair_lock_s()
    private var _runsStarted: Int = 0          // OK — locked storage

    var runsStarted: Int {                     // public reader holds the lock
        os_unfair_lock_lock(&_lock)
        defer { os_unfair_lock_unlock(&_lock) }
        return _runsStarted
    }
}
```

```swift
private func loadDevices(_ filename: String) -> [DeviceDescriptor] { ... }
//                ^ no underscore — pure helper, no shared state
```

Existing locked-storage names (do **not** strip their `_`):

- `CatalogueStore`: `_manifest`, `_generation`, `_jsonCache`, `_jsonDiskReadCount`
- `ObjectCache`: `_lock`, `_counterLock`, `_runsStarted`, `_runsCompleted`,
  `_itemsConsidered`, `_itemsRemoved`
- `BezelImageCache`: `_lock`, `_budgetBytes`
- `ScreenshotConfig`: `_sortedBezelsByOS` (computed-cache backing)
- `TextRenderCache`: `_paraLock`, `_shadowLock`

## "Locks, not actor isolation" pattern

Several singletons (`BezelImageCache`, `CIImageCache`, `ContinuousPathCache`,
`TextRenderCache`, `CatalogueStore`, `GenerationCache`, `BaseURLConfig`,
`ObjectCache`) are `final class … : @unchecked Sendable` with raw
`os_unfair_lock_s` (or `NSLock`) protecting their mutable state.

This is intentional. Reasons:

- **Floor stays at macOS 11 / iOS 14.** `OSAllocatedUnfairLock` lands in
  macOS 13. `actor` works on every floor target, but every read becomes
  `await`, which forces every caller (including `nonisolated static var`
  getters and the synchronous render pipeline) into `async` contexts.
- **Tight critical sections.** Caches do dictionary lookups inside the
  lock and run their builders **outside** the lock. Two threads racing
  on the same cache miss may produce one redundant build (CGPath,
  paragraph style, gradient mask, ...); all such builders are
  thread-safe and the values themselves are immutable, so the duplicate
  is harmless and avoids the worst-case wait.
- **`@unchecked Sendable` is OK here** because the lock is the only path
  to the mutable state. The compiler can't prove it; the contract is
  enforced manually inside the file.

When adding a new bounded cache: copy the `BezelImageCache` shape, hook
`clear()` into `HarnessKitCatalogue.invalidateCaches()`, and add a
bounded-growth test alongside the cache file.

## Bit-for-bit Golden parity is non-negotiable

The image pipeline has 15 Golden fixtures under
`Tests/HarnessKitTransformTests/Golden/Fixtures/`. Any change to the
transform pipeline, canvas renderer, shadow logic, or platform image
helpers **must** keep all 15 byte-identical:

```bash
swift test --filter GoldenTests
# expect: 15/15 passed, 0 failures
```

Pre-existing failure to ignore: `PipelineTests.testRenderCanvas_zeroCanvasSize_returnsEmptyImage`
(the renderer returns 1×1 for a zero-sized canvas; the test expects `.zero`).

When a change *would* shift Golden output (e.g. a CIImage fusion that
adopts different intermediate precision), materialize CIImage → CGImage
at the divergence point. Float4 fusion drift across CIFilter chains is
the usual culprit.

## Quick smoke for any image-pipeline change

Before pushing, run:

```bash
swift build                                # clean
swift test --filter GoldenTests            # 15/15 bit-for-bit
swift test --filter PipelineTests          # 24/25 (zero-canvas excepted)
swift test                                 # 128/129 green
```

For perf-sensitive changes also run:

```bash
swift run -c release HarnessKitBenchmarks --compare Benchmarks/baselines/1.0-baseline.csv
# expect: 6 baseline scenarios within thresholds (mem 5%, time 10%)
```

`CanvasEffectsStress` memory is historically noisy (±18%); persistent
drift outside that band is real.

## Concurrency floor

- Strict concurrency = complete.
- No `@concurrent` (Swift 6.2+).
- No `OSAllocatedUnfairLock` (macOS 13+) — use raw `os_unfair_lock_s` from
  `os.lock`.
- No `Task.sleep(for:)` — use `Task.sleep(nanoseconds:)`.

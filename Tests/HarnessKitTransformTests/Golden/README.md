# Golden Snapshot Tests

Pixel-exact regression tests for the HarnessKit rendering pipeline. Every
optimization PR must pass these — a change that alters pixels either needs
a rationale + fixture regeneration, or it's breaking something.

## Layout

- `GoldenHarness.swift` — `assertMatches` helper, regenerate switch, diff
  output on failure.
- `PixelDiff.swift` — RGBA8 byte comparison with `tolerance`.
- `FixtureBuilders.swift` — one builder function per fixture. Deterministic,
  no external inputs.
- `GoldenTests.swift` — one `XCTestCase` method per fixture.
- `Fixtures/*.png` — reference PNGs committed alongside the code.
- `regenerate.sh` — wrapper for the regenerate flow.

## Run

```sh
swift test --filter GoldenTests
```

A single fixture:

```sh
swift test --filter testCanvasContactShadows3Groups
```

## Intentional changes (regenerate fixtures)

```sh
Tests/HarnessKitTransformTests/Golden/regenerate.sh
git diff --stat Tests/HarnessKitTransformTests/Golden/Fixtures
```

Review the rendered diff. If correct, commit the fixture update in the same
PR as the code change that produced it so the pixel change is reviewable in
one place.

## Failure debugging

When `assertMatches` fails it writes the actual render to
`Fixtures/_failed_<name>.png`. Open it side-by-side with the fixture:

```sh
open Tests/HarnessKitTransformTests/Golden/Fixtures/canvas-effect-blur.png
open Tests/HarnessKitTransformTests/Golden/Fixtures/_failed_canvas-effect-blur.png
```

The failure message names the first divergent pixel (x, y, channel) plus
the number of pixels outside tolerance and the maximum delta — usually
enough to localize which rendering stage broke.

## Scope

Current fixtures cover the **canvas + no-bezel pipeline** scenarios only:

| Fixture | Covers |
|---|---|
| `canvas-solid-background` | Background fill only |
| `canvas-gradient-background` | Linear gradient background |
| `canvas-shape-fill-stroke` | Shape layer with fill + stroke |
| `canvas-text-layer` | Text rendering (Helvetica Neue) |
| `canvas-contact-shadows-3groups` | 3 blur-radius groups — §S3.2 target |
| `canvas-effect-blur` | Single blur effect |
| `canvas-effect-progressive-blur` | Progressive blur — §S3.1 target |
| `canvas-effect-progressive-fade` | Progressive fade (transparent alloc) — §S3.1 + §S3.3 |
| `canvas-multilayer-corner-radius` | Multi-layer with corner radius — §S3.5 |
| `no-bezel-pipeline-portrait` | Full no-bezel pipeline — §S2.2 + §S4 |

Bezel-dependent fixtures (MacBook / iPhone / iPad / AppleWatch / AppleTV /
VisionPro with real bezels) are **intentionally omitted** — the current
package ships only JSON catalogues, not bundled bezel PNGs. Those will be
added later once bundled baseline bezels (or a CI-friendly prefetch step)
exists.

## Caveats

- macOS-only. iOS/iPadOS rasterization differs at the CG level; a separate
  iOS golden harness is a future task.
- Tolerance defaults to `1` per channel to absorb CG rounding slack. If a
  legitimate optimization (e.g. fused CIFilter chain) shifts pixels beyond
  tolerance, either tighten the scenario or bump tolerance explicitly in
  the call site.
- Fonts pinned to Helvetica Neue — stable across recent macOS versions.
  SF Pro was rejected because its metrics shifted between major OS
  releases.

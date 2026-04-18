#!/usr/bin/env bash
# profile.sh — one-shot Instruments recording for the benchmark binary.
#
# Apple ships `.tracetemplate` as a proprietary binary bundle with an
# Xcode-version-dependent format. Hand-authoring one is fragile, so this
# script uses `xctrace record` with the built-in standard templates
# instead — same end result (a `.trace` you open in Instruments.app) with
# no fragile binaries checked in.
#
# Usage:
#   Benchmarks/profile.sh                          # Allocations, all scenarios
#   Benchmarks/profile.sh time                     # Time Profiler
#   Benchmarks/profile.sh leaks                    # Leaks
#   Benchmarks/profile.sh concurrency              # Swift Concurrency
#   Benchmarks/profile.sh allocations CanvasShadowStress-4K-3groups
#
# Arguments:
#   $1  template shortcut: alloc|allocations|time|profile|leaks|concurrency
#       (default: alloc)
#   $2  optional --only filter passed to HarnessKitBenchmarks
#
# Requires Xcode + `xcrun xctrace` on PATH.

set -euo pipefail

cd "$(dirname "$0")/.."

SHORT="${1:-alloc}"
FILTER="${2:-}"

case "$SHORT" in
    alloc|allocations) TEMPLATE="Allocations"        ;;
    time|profile)      TEMPLATE="Time Profiler"      ;;
    leaks)             TEMPLATE="Leaks"              ;;
    concurrency)       TEMPLATE="Swift Concurrency"  ;;
    system)            TEMPLATE="System Trace"       ;;
    *)
        echo "Unknown template shortcut: $SHORT" >&2
        echo "Available: alloc | time | leaks | concurrency | system" >&2
        exit 2
        ;;
esac

# Build release binary so we profile optimized code, not debug.
echo "==> Building HarnessKitBenchmarks (release)"
swift build --product HarnessKitBenchmarks -c release

# Resolve the binary path — SwiftPM puts it under a platform-specific subdir.
BINARY="$(swift build --product HarnessKitBenchmarks -c release --show-bin-path)/HarnessKitBenchmarks"
if [ ! -x "$BINARY" ]; then
    echo "Could not locate built binary at $BINARY" >&2
    exit 3
fi

# Output location. Timestamped so successive runs don't collide.
STAMP="$(date +%Y%m%d-%H%M%S)"
TRACE_NAME="$(echo "$TEMPLATE" | tr ' ' '-').$STAMP.trace"
OUT_DIR=".bench-out"
mkdir -p "$OUT_DIR"
OUT_PATH="$OUT_DIR/$TRACE_NAME"

# Assemble launch args — filter passes through via the benchmark CLI.
LAUNCH_ARGS=()
if [ -n "$FILTER" ]; then
    LAUNCH_ARGS+=(--only "$FILTER")
fi

echo "==> Recording '$TEMPLATE' → $OUT_PATH"
xcrun xctrace record \
    --template "$TEMPLATE" \
    --output "$OUT_PATH" \
    --launch -- "$BINARY" "${LAUNCH_ARGS[@]+"${LAUNCH_ARGS[@]}"}"

echo "==> Opening trace in Instruments"
open "$OUT_PATH"

cat <<EOF

Done.
  Trace file: $OUT_PATH
  Re-open later with:
    open '$OUT_PATH'
EOF

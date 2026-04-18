#!/usr/bin/env bash
# Regenerate every golden fixture from the current rendering pipeline.
# Run this after an intentional pixel-level change, inspect the diff, then
# commit the updated Fixtures/*.png alongside the code change that produced
# them.
#
# Usage:
#   Tests/HarnessKitTransformTests/Golden/regenerate.sh
#   Tests/HarnessKitTransformTests/Golden/regenerate.sh --filter testCanvasTextLayer

set -euo pipefail

cd "$(dirname "$0")/../../.."

HARNESS_REGENERATE_FIXTURES=1 swift test --filter GoldenTests "$@"

echo
echo "Fixtures regenerated. Review with:"
echo "  git diff --stat Tests/HarnessKitTransformTests/Golden/Fixtures"
echo "Then run normal tests to confirm everything still matches:"
echo "  swift test --filter GoldenTests"

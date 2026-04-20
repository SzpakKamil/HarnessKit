//
//  blur.metal
//  ForkedGlur
//
//  Fork of upstream Glur's blur shader. Three changes from upstream:
//
//  1. The `clamp(...)` call that pinned each sample coordinate to
//     `[0, size - 1]` is removed. With the companion
//     `maxSampleOffset: radius × overflow` passed from
//     `GlurModifier.swift`, SwiftUI now hands the shader a source
//     buffer that extends past the view's natural bounds with
//     transparent pixels — sampling without the clamp lets the
//     Gaussian kernel pick up those transparent pixels and produce a
//     smooth alpha-fade halo instead of smearing the edge color outward.
//
//  2. **Smoothly tapered adaptive tap count.** Upstream ran a fixed
//     64-tap loop regardless of radius. We compute the Gaussian
//     half-support as a *float* (`halfSupport = 3σ/step`) and:
//        - cap the loop at `ceil(halfSupport)` so low-radius pixels
//          skip taps that carry no useful weight (5-10× win at r<5);
//        - multiply each tap's Gaussian weight by a continuous
//          roll-off `clamp(halfSupport - i + 1, 0, 1)` so the
//          boundary tap fades in/out smoothly as `r` varies across
//          adjacent pixels. Without this, integer-valued tap counts
//          produced a 1-tap discrete jump at every row where
//          `halfSupport` crossed an integer — visible as horizontal
//          seams in the fade region of progressive blur.
//
//  3. **Linear-pair sampling (Sigg/Hadwiger), gated on step ≤ 1.**
//     When sample step is 1 px, two adjacent symmetric taps `(+i, +i+1)`
//     can be folded into a single bilinear-filtered fetch each side
//     by sampling at the weighted midpoint — bilinear exactly
//     reconstructs `w1·sample(i) + w2·sample(i+1)`. Above step = 1
//     (i.e., r > ~10.3) the midpoint bilinear reads the two source
//     pixels nearest the midpoint, NOT the two intended tap positions.
//     The drift compounds across taps and produces visible echo bands
//     of the source content. So we only run the paired loop when
//     `step <= 1.0`; above that, fall back to a single-tap loop.
//
//  4. **Single-shot normalization.** Upstream computed all 64 weights,
//     summed them, then divided each weight by the sum (64 divides per
//     pixel). We accumulate `wsum` alongside the result and divide
//     once at return — one divide per pixel.
//

#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
using namespace metal;

/// Maximum half-support of the Gaussian, in taps each side of the
/// center. With pairing on step≤1, the inner loop touches at most
/// `ceil(maxHalfTaps / 2) = 16` iterations × 2 samples = 32 fetches
/// per axis (plus the center). Single-tap path at step>1 touches up
/// to `maxHalfTaps × 2 = 62` fetches — same order as upstream's 64.
#define maxHalfTaps (31)

float mapRadius(float2 position,
                float2 size,
                float offset,
                float interpolation,
                float radius,
                float direction) {
    float mapped = 0.0;

    if (direction == 0) {
        mapped = max((position.y/size.y-offset)/interpolation, 0.0);
    } else if (direction == 1) {
        mapped = max(0.5-(position.y/size.y-offset)/interpolation, 0.0);
    } else if (direction == 2) {
        mapped = max((position.x/size.x-offset)/interpolation, 0.0);
    } else if (direction == 3) {
        mapped = max(0.5-(position.x/size.x-offset)/interpolation, 0.0);
    }

    return min(mapped*radius, radius);
}

/// Per-sample distance in pixels. With `maxHalfTaps = 31` each side,
/// `2*maxHalfTaps = 62` taps span ±3σ when `step = 6r/62 = 3r/31`.
/// Floored at 1 px so small-radius behavior stays dense (no skipping
/// inside the actual support).
float sampleStep(float radius) {
    return max(1.0, (6.0 * radius) / float(2 * maxHalfTaps));
}

/// Shared body for both axis passes. `axis` is `(1,0)` for horizontal,
/// `(0,1)` for vertical — picked by the `[[ stitchable ]]` entry
/// points below.
half4 blurAxis(float2 position,
               SwiftUI::Layer layer,
               float radius,
               float offset,
               float interpolation,
               float direction,
               float2 size,
               float2 axis) {
    float r = mapRadius(position,
                        size,
                        offset,
                        interpolation,
                        radius,
                        direction);

    if (r == 0.0) {
        return layer.sample(position);
    }

    float step        = sampleStep(r);
    float twoRSq      = 2.0 * r * r;
    float halfSupport = 3.0 * r / step;
    int   halfTaps    = min(maxHalfTaps, int(ceil(halfSupport)));

    // Center sample, weight = exp(0) = 1.
    float4 result = float4(layer.sample(position));
    float  wsum   = 1.0;

    if (step > 1.0) {
        // Single-tap path. Linear-pair midpoint trick is only exact
        // when paired taps are within 1 px of each other (bilinear
        // blends the same two source pixels we'd manually weight).
        // Above step = 1 the midpoint bilinear samples drift off the
        // intended positions, producing visible echo bands of the
        // source content in the fade region.
        for (int i = 1; i <= halfTaps; ++i) {
            float xi   = float(i) * step;
            float fade = clamp(halfSupport - float(i) + 1.0, 0.0, 1.0);
            float w    = metal::fast::exp(-(xi*xi) / twoRSq) * fade;
            float2 dp  = axis * xi;
            result += (float4(layer.sample(position + dp))
                     + float4(layer.sample(position - dp))) * w;
            wsum   += 2.0 * w;
        }
    } else {
        // Linear-pair path. step == 1 → adjacent tap positions are
        // exactly 1 px apart; bilinear sample at the weighted midpoint
        // exactly reconstructs `w1·sample(i) + w2·sample(i+1)`.
        for (int i = 1; i <= halfTaps; i += 2) {
            float xi    = float(i)     * step;
            float xj    = float(i + 1) * step;
            float fadeI = clamp(halfSupport - float(i)     + 1.0, 0.0, 1.0);
            float fadeJ = clamp(halfSupport - float(i + 1) + 1.0, 0.0, 1.0);
            float w1    = metal::fast::exp(-(xi*xi) / twoRSq) * fadeI;
            float w2    = (i + 1 <= halfTaps)
                          ? metal::fast::exp(-(xj*xj) / twoRSq) * fadeJ
                          : 0.0;
            float W     = w1 + w2;
            // Guard against W = 0 (both fades zeroed out at the very
            // tail) so the midpoint formula doesn't divide by zero.
            float O     = (W > 0.0) ? (xi * w1 + xj * w2) / W : xi;

            float2 dp = axis * O;
            result += (float4(layer.sample(position + dp))
                     + float4(layer.sample(position - dp))) * W;
            wsum   += 2.0 * W;
        }
    }

    // Single-shot normalization — divide once per pixel rather than
    // dividing every weight before sampling.
    return half4(result / wsum);
}

[[ stitchable ]] half4 blurX(float2 position,
                             SwiftUI::Layer layer,
                             float radius,
                             float offset,
                             float interpolation,
                             float direction,
                             float2 size) {
    return blurAxis(position, layer, radius, offset, interpolation,
                    direction, size, float2(1.0, 0.0));
}

[[ stitchable ]] half4 blurY(float2 position,
                             SwiftUI::Layer layer,
                             float radius,
                             float offset,
                             float interpolation,
                             float direction,
                             float2 size) {
    return blurAxis(position, layer, radius, offset, interpolation,
                    direction, size, float2(0.0, 1.0));
}

// CoreImage entry points live in `blur_ci.metal` (loaded at runtime
// by `HeadlessBlur.swift` via `CIKernel.kernels(withMetalString:)`) —
// they need the `-fcikernel` compile flag that only CoreImage's
// runtime compiler applies, so they can't ship in this metallib.

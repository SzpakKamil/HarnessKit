//
//  ProgressiveBlurModifier.swift
//  HarnessKitTransform
//
//  SwiftUI-side progressive blur, shared with the headless export
//  path (`applyMetalProgressiveBlur` in `MetalProgressiveBlur.swift`).
//  Both route through the same Gaussian math compiled from
//  `Resources/blur.metal` (SwiftUI `.layerEffect` stitchable shaders)
//  and `Resources/blur_ci.metalsrc` (CoreImage kernels) — the only
//  difference between the two is the Metal entry-point signature
//  (`SwiftUI::Layer::sample(pixel)` vs
//  `coreimage::sampler::sample(srcCoord)`).
//
//  Originally ForkedGlur (a fork of joogps/Glur) at
//  `Packages/ForkedGlur`, merged into HarnessKitTransform so Framely
//  no longer needs a separate preview-only SwiftUI package. Framely
//  imports `HarnessKitTransform` and calls `.overflowGlur(...)`
//  directly.
//

import SwiftUI

public extension View {
    /// Applies a gradient-masked blur that overflows the source
    /// view's bounds, unlike stock SwiftUI `.blur(radius:)` + mask
    /// compositions which hard-clip the halo at the view rect.
    ///
    /// - Parameters:
    ///   - radius: Total radius when the gradient mask reaches 1.0.
    ///   - offset: Where along `direction` the effect begins,
    ///     normalized to `[0, 1]` over the source's natural bounds.
    ///   - interpolation: Length of the ramp between `offset` and
    ///     full-radius, also normalized.
    ///   - direction: Axis the blur ramps along. Uses
    ///     `ProgressiveBlurDirection` — same enum the export-side
    ///     effect model uses.
    ///   - noise: Post-blur grain strength in the faded region.
    ///     Default `0`; the improved Metal shader here doesn't need
    ///     Glur's upstream-default noise pass to mask precision
    ///     artifacts.
    ///   - drawingGroup: Whether to pre-rasterize the source into
    ///     one texture before the blur pass. Leave `true` for
    ///     layered SwiftUI content that would otherwise be
    ///     re-rasterized per blur sample.
    ///   - overflow: Fraction of `radius` to reserve outside the
    ///     source view for the halo. Default `3` covers ~99.7% of
    ///     the Gaussian tail; bump to 5–6 for effectively invisible
    ///     fade at the boundary.
    ///   - useMetalShader: `true` uses the Metal stitchable shader
    ///     (iOS 17 / macOS 14+) for TRUE per-pixel variable-radius
    ///     blur. `false` uses the CA-style `.blur(radius:) + .mask`
    ///     compatibility path, which matches what the HarnessKit
    ///     export did before the Metal integration.
    func progressiveBlur(radius: CGFloat = 8.0,
                         offset: CGFloat = 0.3,
                         interpolation: CGFloat = 0.4,
                         direction: ProgressiveBlurDirection = .topToBottom,
                         noise: CGFloat = 0.0,
                         drawingGroup: Bool = true,
                         overflow: CGFloat = 3.0,
                         useMetalShader: Bool = false) -> some View {
        assert(radius >= 0.0, "Radius must be >= 0")
        assert(offset >= 0.0 && offset <= 1.0, "Offset must be in [0, 1]")
        assert(interpolation >= 0.0 && interpolation <= 1.0, "Interpolation must be in [0, 1]")
        assert(noise >= 0.0, "Noise must be >= 0")
        assert(overflow >= 0.0, "Overflow must be >= 0")

        if useMetalShader, #available(iOS 17.0, macOS 14.0, tvOS 17.0, visionOS 1.0, *) {
            return AnyView(
                modifier(ProgressiveBlurMetalModifier(
                    radius: radius,
                    offset: offset,
                    interpolation: interpolation,
                    direction: direction,
                    noise: noise,
                    drawingGroup: drawingGroup,
                    overflow: overflow
                ))
            )
        } else {
            return AnyView(
                modifier(ProgressiveBlurCompatModifier(
                    radius: radius,
                    offset: offset,
                    interpolation: interpolation,
                    direction: direction,
                    drawingGroup: drawingGroup,
                    overflow: overflow
                ))
            )
        }
    }
}

// MARK: - SwiftUI direction ↔ shader int encoding

/// Integer the Metal shader expects in its `direction` parameter.
/// Matches the ladder inside `blur.metal`/`blur_ci.metalsrc`'s
/// `mapRadius`: 0=down, 1=up, 2=right, 3=left.
internal extension ProgressiveBlurDirection {
    var shaderEncoded: Int {
        switch self {
        case .topToBottom: return 0
        case .bottomToTop: return 1
        case .leftToRight: return 2
        case .rightToLeft: return 3
        }
    }

    var swiftUIUnitPoints: (UnitPoint, UnitPoint) {
        switch self {
        case .topToBottom: return (.top, .bottom)
        case .bottomToTop: return (.bottom, .top)
        case .leftToRight: return (.leading, .trailing)
        case .rightToLeft: return (.trailing, .leading)
        }
    }
}

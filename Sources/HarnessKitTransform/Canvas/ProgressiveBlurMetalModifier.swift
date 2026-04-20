//
//  ProgressiveBlurMetalModifier.swift
//  HarnessKitTransform
//
//  SwiftUI `.layerEffect`-backed variant of the progressive blur.
//  Runs the stitchable shaders in `Resources/blur.metal`. Same
//  Gaussian math as the headless `MetalProgressiveBlur` CIKernel
//  path — see `Resources/blur_ci.metalsrc` for the twin entry
//  points — so the interactive canvas and the exported PNG render
//  from identical math.
//
//  Notable differences vs. upstream Glur:
//    - `maxSampleOffset: CGSize(radius × overflow)` instead of
//      `.zero`, so SwiftUI allocates a transparent extension buffer
//      around the source and the Gaussian kernel can fade into it
//      (halo overflow).
//    - Noise pass is conditional on `noise > 0` (default is 0)
//      instead of always applied.
//    - The shader itself (in `blur.metal`) has a radius-scaled
//      sample step and float-precision accumulator so the kernel
//      actually covers ±3σ at any radius, and avoids half-float
//      drift across 64 taps.
//

import SwiftUI

@available(iOS 17.0, macOS 14.0, tvOS 17.0, visionOS 1.0, *)
internal struct ProgressiveBlurMetalModifier: ViewModifier {
    var radius: CGFloat
    var offset: CGFloat
    var interpolation: CGFloat
    var direction: ProgressiveBlurDirection
    var noise: CGFloat
    var drawingGroup: Bool
    var overflow: CGFloat

    @State private var size: CGSize = .zero

    private let library = ShaderLibrary.bundle(.module)

    private var blurX: Shader {
        var shader = library.blurX(.float(Float(radius)),
                                   .float(Float(offset)),
                                   .float(Float(interpolation)),
                                   .float(Float(direction.shaderEncoded)),
                                   .float2(size))
        shader.dithersColor = true
        return shader
    }

    private var blurY: Shader {
        var shader = library.blurY(.float(Float(radius)),
                                   .float(Float(offset)),
                                   .float(Float(interpolation)),
                                   .float(Float(direction.shaderEncoded)),
                                   .float2(size))
        shader.dithersColor = true
        return shader
    }

    private var noiseShader: Shader {
        var shader = library.noise(.float(Float(noise)),
                                   .float(Float(offset)),
                                   .float(Float(interpolation)),
                                   .float(Float(direction.shaderEncoded)),
                                   .float2(size))
        shader.dithersColor = true
        return shader
    }

    /// `radius × overflow` — at overflow=3 this covers ~99.7% of the
    /// Gaussian tail, i.e. the point where the halo is
    /// indistinguishable from full transparency.
    private var sampleOffset: CGSize {
        let pad = max(0, radius * overflow)
        return CGSize(width: pad, height: pad)
    }

    @ViewBuilder
    func body(content: Content) -> some View {
        if radius.isZero {
            content
        } else {
            Group {
                if drawingGroup {
                    content.drawingGroup()
                } else {
                    content
                }
            }
            .overlay {
                GeometryReader { proxy in
                    Color.clear
                        .preference(key: ProgressiveBlurSizePreferenceKey.self,
                                    value: proxy.size)
                }
                .allowsHitTesting(false)
            }
            .onPreferenceChange(ProgressiveBlurSizePreferenceKey.self) { size in
                self.size = size
            }
            .layerEffect(blurX, maxSampleOffset: sampleOffset)
            .layerEffect(blurY, maxSampleOffset: sampleOffset)
            // Noise only decorates visible pixels; skip when not
            // requested (the default), so the clean
            // scaled-kernel/float-accumulator output isn't sprayed
            // with grain designed to mask upstream's
            // half-precision artifacts.
            .layerEffect(noiseShader, maxSampleOffset: .zero, isEnabled: noise > 0)
        }
    }
}

private struct ProgressiveBlurSizePreferenceKey: PreferenceKey {
    // Computed (not stored) so Swift 6's strict concurrency doesn't
    // flag this as nonisolated shared mutable state. Glur's upstream
    // declares it as a stored `var`, which is fine under Swift 5
    // but trips `#MutableGlobalVariable` on Swift 6.
    static var defaultValue: CGSize { .zero }

    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

//
//  ProgressiveBlurCompatModifier.swift
//  HarnessKitTransform
//
//  Fallback path for the SwiftUI progressive blur when the Metal
//  stitchable shader isn't available (iOS < 17 / macOS < 14) or
//  the caller explicitly opts out via `useMetalShader: false`.
//
//  Builds the effect out of SwiftUI's native `.blur(radius:)` and a
//  linear gradient mask. `.blur(...)` composites via CA filters and
//  overflows its view's bounds naturally, so the `padding(radius ×
//  overflow)` trick here widens the masked region past the source
//  rect and keeps the halo from being nulled by the mask's `.clear`
//  end.
//

import SwiftUI

internal struct ProgressiveBlurCompatModifier: ViewModifier {
    var radius: CGFloat
    var offset: CGFloat
    var interpolation: CGFloat
    var direction: ProgressiveBlurDirection
    var drawingGroup: Bool
    var overflow: CGFloat

    @ViewBuilder
    func body(content: Content) -> some View {
        if radius.isZero {
            content
        } else {
            content
                .overlay {
                    Group {
                        if drawingGroup {
                            content.drawingGroup()
                        } else {
                            content
                        }
                    }
                    .allowsHitTesting(false)
                    .blur(radius: radius)
                    .scaleEffect(1 + (radius * 0.02))
                    .padding(radius * overflow)
                    .mask(gradientMask)
                }
        }
    }

    /// `.clear → .clear @ offset → .black @ offset+interpolation`
    /// — content stays hidden up to `offset`, fades in through the
    /// interpolation zone, stays visible (black mask = show) past
    /// `offset + interpolation`.
    private var gradientMask: some View {
        let (start, end) = direction.swiftUIUnitPoints
        return LinearGradient(
            stops: [
                .init(color: .clear, location: 0),
                .init(color: .clear, location: offset),
                .init(color: .black, location: offset + interpolation),
            ],
            startPoint: start,
            endPoint: end
        )
    }
}

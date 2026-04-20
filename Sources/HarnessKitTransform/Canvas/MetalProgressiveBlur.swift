//
//  MetalProgressiveBlur.swift
//  HarnessKitTransform
//
//  CoreImage-native progressive blur shared with Framely's preview
//  path (`ForkedGlur.overflowGlur(useMetalShader: true)`). The shader
//  source (`Resources/blur_ci.metalsrc`) carries the same Gaussian
//  math used by the SwiftUI `.layerEffect` variant on the preview
//  side — scaled 64-tap kernel, float-precision accumulator,
//  no-clamp halo, integer-centered sample offsets. Any bug fix to
//  the math needs a matching fix in ForkedGlur's `blur.metal`.
//
//  Runs on any thread (`nonisolated`, no SwiftUI) so the export
//  pipeline in `applyCanvasEffect(.progressiveBlur)` can use it
//  without a MainActor hop.
//

import Foundation
import CoreImage
import CoreGraphics
import os.log

/// Shared logger + once-per-process "metal blur fell back" warning.
/// Emits to `os_log` so a Framely-style release build shows the
/// message in Console.app even when no debugger is attached.
enum SharedBlurDiagnostic {
    private static let log = OSLog(subsystem: "HarnessKitTransform", category: "ProgressiveBlur")
    private final class State: @unchecked Sendable {
        var warnedFallback = false
        var warnedSuccess = false
        let lock = NSLock()
    }
    private static let state = State()

    /// `.fault`-level so the message always surfaces in Console.app
    /// regardless of the user's default filter. These are meant to
    /// be seen; the fallback path silently producing wrong-looking
    /// output was the whole bug.
    static func warn(_ message: String) {
        os_log("%{public}@", log: log, type: .fault, message)
    }

    static func warnFallback() {
        state.lock.lock()
        defer { state.lock.unlock() }
        guard !state.warnedFallback else { return }
        state.warnedFallback = true
        os_log("Metal progressive-blur kernel unavailable; using CIGaussianBlur + blendWithMask fallback. First-time only diagnostic.",
               log: log, type: .fault)
    }

    /// Called once on the first successful kernel compile so the
    /// Metal path's presence is confirmable from Console without
    /// needing to hit the fallback first.
    static func noteMetalReady() {
        state.lock.lock()
        defer { state.lock.unlock() }
        guard !state.warnedSuccess else { return }
        state.warnedSuccess = true
        os_log("Metal progressive-blur kernels compiled and ready.",
               log: log, type: .info)
    }
}

/// Mirrors Glur's `BlurDirection.Evaluated` so the shader's integer
/// `direction` parameter is easy to spell in Swift. Order matches the
/// ladder inside `mapRadius` in `blur_ci.metalsrc`.
enum MetalBlurDirection: Int {
    case down = 0
    case up = 1
    case right = 2
    case left = 3
}

/// Applies a two-pass per-pixel variable-radius progressive blur via
/// the CoreImage kernels compiled from `blur_ci.metalsrc`. Returns
/// the blurred `CIImage` cropped to `extent` — the caller
/// materializes via `SharedCIContext` (or any other `CIContext`) as
/// usual.
///
/// Gated by `@available(macOS 12, iOS 15, tvOS 15, visionOS 1, *)`
/// because `CIKernel.kernels(withMetalString:)` only ships on that
/// baseline. Older OS versions fall back to the legacy
/// `gaussianBlur + blendWithMaskCI` path inside
/// `applyCanvasEffect(.progressiveBlur)` via an `#available` check.
/// - Parameters:
///   - ci: Source image (may include transparent halo padding so
///     the blur halo has room to render outside the authored frame).
///   - radius: Maximum blur radius in pixels. `0` early-exits.
///   - offset: Gradient offset along `direction`, normalized to
///     `[0, 1]` over the frame (see `contentRect`).
///   - interpolation: Normalized length of the sharp→full-radius
///     ramp. Clamped to `≥ 0.001` to avoid a divide-by-zero in the
///     shader.
///   - direction: Axis the ramp runs along.
///   - extent: Apply rect — equal to the source's extent for a
///     padded source. Kernel writes every pixel in this rect.
///   - contentRect: The authored frame rect INSIDE `extent`. When
///     `ci` is halo-padded, this is `CGRect(x: halo, y: halo, width:
///     frame.width, height: frame.height)`. The shader uses this to
///     compute gradient coords so `startPoint`/`endPoint` align with
///     the frame edges exactly — without it the gradient stretches
///     across the padded extent and the content sees a compressed,
///     visibly weaker blur.
@available(macOS 12, iOS 15, tvOS 15, visionOS 1, *)
func applyMetalProgressiveBlur(
    to ci: CIImage,
    radius: Double,
    offset: Double,
    interpolation: Double,
    direction: MetalBlurDirection,
    extent: CGRect,
    contentRect: CGRect
) -> CIImage? {
    guard radius > 0, extent.width > 0, extent.height > 0 else { return ci }

    guard let (blurX, blurY) = MetalProgressiveBlurKernels.shared else { return nil }

    // Explicitly bound the sampler's extent to `extent`. Without
    // `.cropped(to:)` the default CIKernel sampling mode for a
    // CGImage-backed CIImage is edge-clamp — so any sample past the
    // padded extent (which happens at max radius near the halo
    // edges) returns the EDGE pixel, not transparent. That's what
    // produced the vertical-streak / wine-glass-cone artifacts in
    // the iPad export: the Gaussian kernel was multiplying in copies
    // of the edge bezel pixel and smearing them outward.
    let boundedCI = ci.cropped(to: extent)

    let r = CGFloat(radius)
    let interp = max(0.001, CGFloat(interpolation))
    // CIKernel argument bridging: `NSNumber` for scalars, `CIVector`
    // for float2/3/4, `CIImage` for samplers. Passing raw Swift
    // `Float` works for some CI versions but silently fails on
    // others, which is exactly how we ended up in the fallback path
    // in Framely builds.
    let radiusArg = NSNumber(value: Double(radius))
    let offsetArg = NSNumber(value: Double(offset))
    let interpArg = NSNumber(value: Double(interp))
    let directionArg = NSNumber(value: Int(direction.rawValue))
    let contentOrigin = CIVector(x: contentRect.origin.x, y: contentRect.origin.y)
    let contentSize = CIVector(x: contentRect.width, y: contentRect.height)

    // Each separable pass samples up to `3 × radius` pixels on its
    // axis (`sampleStep × centerIndex` in the shader). CoreImage's
    // ROI callback widens the requested output rect on only that
    // pass's axis.
    let halo = r * 3

    let xArgs: [Any] = [
        boundedCI, radiusArg, offsetArg, interpArg, directionArg,
        contentOrigin, contentSize,
    ]
    guard let xOutput = blurX.apply(
        extent: extent,
        roiCallback: { _, rect in rect.insetBy(dx: -halo, dy: 0) },
        arguments: xArgs
    ) else {
        SharedBlurDiagnostic.warn("blurX_ci.apply(extent:roiCallback:arguments:) returned nil — likely an argument-type bridging issue or an out-of-bounds extent.")
        return nil
    }

    let yArgs: [Any] = [
        xOutput.cropped(to: extent), radiusArg, offsetArg, interpArg, directionArg,
        contentOrigin, contentSize,
    ]
    guard let yOutput = blurY.apply(
        extent: extent,
        roiCallback: { _, rect in rect.insetBy(dx: 0, dy: -halo) },
        arguments: yArgs
    ) else {
        SharedBlurDiagnostic.warn("blurY_ci.apply(...) returned nil — likely an argument-type bridging issue or an out-of-bounds extent.")
        return nil
    }

    return yOutput.cropped(to: extent)
}

// MARK: - Kernel loader

/// Compiles `blur_ci.metalsrc` from the target's resource bundle ONCE
/// per process. `CIKernel.kernels(withMetalString:)` applies the
/// `-fcikernel` flag internally so `coreimage::sampler::sample /
/// coord / transform` resolve without the build-time link error the
/// regular Metal pipeline would produce.
///
/// Extension is `.metalsrc` (not `.metal`) so Xcode's SPM resource
/// handling doesn't sweep the file into a stitchable-Metal build
/// alongside anything else in the target (which would duplicate
/// helper symbols).
@available(macOS 12, iOS 15, tvOS 15, visionOS 1, *)
private enum MetalProgressiveBlurKernels {
    static let shared: (blurX: CIKernel, blurY: CIKernel)? = load()

    private static func load() -> (blurX: CIKernel, blurY: CIKernel)? {
        guard let url = Bundle.module.url(forResource: "blur_ci", withExtension: "metalsrc") else {
            SharedBlurDiagnostic.warn("blur_ci.metalsrc not found in Bundle.module — resource not packaged?")
            return nil
        }
        guard let source = try? String(contentsOf: url, encoding: .utf8) else {
            SharedBlurDiagnostic.warn("blur_ci.metalsrc located but unreadable at \(url.path)")
            return nil
        }

        let kernels: [CIKernel]
        do {
            kernels = try CIKernel.kernels(withMetalString: source)
        } catch {
            SharedBlurDiagnostic.warn("CIKernel.kernels(withMetalString:) failed: \(error)")
            return nil
        }

        var blurX: CIKernel?
        var blurY: CIKernel?
        for kernel in kernels {
            switch kernel.name {
            case "blurX_ci": blurX = kernel
            case "blurY_ci": blurY = kernel
            default: break
            }
        }

        guard let x = blurX, let y = blurY else {
            SharedBlurDiagnostic.warn("Expected blurX_ci/blurY_ci kernels; got \(kernels.map { $0.name })")
            return nil
        }
        SharedBlurDiagnostic.noteMetalReady()
        return (x, y)
    }
}

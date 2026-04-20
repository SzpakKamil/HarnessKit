import Foundation
import CoreGraphics
import CoreImage
import CoreImage.CIFilterBuiltins
import HarnessKitScreenshots

// MARK: - Effects

/// Applies a chain of `CanvasLayerEffect`s to `image`.
///
/// Blur/progressive-blur/progressive-fade/colorOverlay stay in
/// `CIImage` space for the whole chain and materialize to a
/// `PlatformImage` once at the end — a four-effect chain used to
/// allocate four canvas-sized bitmaps + four `createCGImage`
/// renders; now it's one. `.cornerRadius` and `.border` are
/// geometric operations without a clean `CIFilter` equivalent
/// (continuous-corner paths, stroked outlines), so they break the
/// fusion: materialize the current `CIImage`, apply the CG-based
/// helper, re-wrap. Callers should place those effects first or
/// last in the chain to keep fusion maximal.
/// When `image` is halo-padded (`Renderer.swift` pads the content
/// bitmap to give blur halos room past the authored frame), pass the
/// frame's rect inside the padded extent as `contentRect`. Without
/// it, progressive blur's gradient stretches across the padded
/// extent and the content sees a compressed, visibly weaker blur
/// vs. the SwiftUI preview (which runs on a view sized exactly to
/// the frame).
func applyCanvasEffects(
    to image: PlatformImage,
    effects: [CanvasLayerEffect],
    contentRect: CGRect? = nil
) -> PlatformImage {
    guard !effects.isEmpty else { return image }
    guard let input = cgImage(from: image) else { return image }

    var ci: CIImage = CIImage(cgImage: input)
    let extent = ci.extent
    let size = imageSize(image)
    let content = contentRect ?? extent

    for effect in effects {
        ci = applyCanvasEffect(to: ci, effect: effect, extent: extent, size: size, contentRect: content)
    }

    guard let out = SharedCIContext.context.createCGImage(ci, from: extent) else {
        return image
    }
    return platformImage(from: out, size: size)
}

func applyCanvasEffect(
    to ci: CIImage,
    effect: CanvasLayerEffect,
    extent: CGRect,
    size: CGSize,
    contentRect: CGRect
) -> CIImage {
    switch effect {
    case .blur(let radius):
        guard radius > 0 else { return ci }
        return gaussianBlur(ci, radius: radius).cropped(to: extent)

    case .progressiveBlur(let radius, let direction, let startPoint, let endPoint):
        guard radius > 0 else { return ci }
        // Try the CoreImage kernel path first (macOS 12 / iOS 15+).
        // Compiled from `Resources/blur_ci.metalsrc` — per-pixel
        // variable-radius blur matching Framely's preview shader.
        if #available(macOS 12, iOS 15, tvOS 15, visionOS 1, *) {
            if let metalOutput = applyMetalProgressiveBlur(
                to: ci,
                radius: radius,
                offset: startPoint,
                interpolation: endPoint - startPoint,
                direction: metalBlurDirection(from: direction),
                extent: extent,
                contentRect: contentRect
            ) {
                return metalOutput
            }
            // Metal path returned nil (kernel compile failure,
            // no Metal device, etc.) — don't silently export the
            // SHARP source; fall through to the legacy
            // `gaussianBlur + blendWithMaskCI` path. Emits a
            // diagnostic so the failure is visible in Console when
            // running a release build.
            SharedBlurDiagnostic.warnFallback()
        }
        // Legacy full-blur + linear-gradient-mask composition. Not
        // per-pixel variable radius — it's "sharp blended with
        // fully-blurred" — but the fade position + intensity still
        // reads as a progressive blur.
        let blurredCI = gaussianBlur(ci, radius: radius).cropped(to: extent)
        guard let blurredCG = SharedCIContext.context.createCGImage(blurredCI, from: extent) else {
            return ci
        }
        let blurredQuantized = CIImage(cgImage: blurredCG)
        guard let mask = gradientMaskCI(size: size, direction: direction, start: startPoint, end: endPoint) else { return ci }
        return blendWithMaskCI(sharp: ci, background: blurredQuantized, mask: mask, extent: extent)

    case .progressiveFade(let direction, let startPoint, let endPoint):
        let transparent = CIImage(color: CIColor.clear).cropped(to: extent)
        guard let mask = gradientMaskCI(size: size, direction: direction, start: startPoint, end: endPoint) else { return ci }
        return blendWithMaskCI(sharp: ci, background: transparent, mask: mask, extent: extent)

    case .colorOverlay(let hex, let opacity):
        let overlay = CIImage(color: CIColor(cgColor: platformColor(hex: hex, opacity: opacity).cgColor))
            .cropped(to: extent)
        if #available(macOS 12.0, iOS 15.0, visionOS 1.0, *) {
            let blend = CIFilter.sourceAtopCompositing()
            blend.inputImage = overlay
            blend.backgroundImage = ci
            return (blend.outputImage ?? ci).cropped(to: extent)
        } else {
            guard let f = CIFilter(name: "CISourceAtopCompositing") else { return ci }
            f.setValue(overlay, forKey: kCIInputImageKey)
            f.setValue(ci, forKey: kCIInputBackgroundImageKey)
            return (f.outputImage ?? ci).cropped(to: extent)
        }

    case .cornerRadius(let radius):
        // Geometric clip. Materialize, clip (continuous corners need
        // a CGPath), re-wrap as CIImage so subsequent effects fuse.
        guard let cg = SharedCIContext.context.createCGImage(ci, from: extent) else { return ci }
        let clipped = applyCanvasCornerRadius(to: platformImage(from: cg, size: size), radius: radius)
        guard let clippedCG = cgImage(from: clipped) else { return ci }
        return CIImage(cgImage: clippedCG).cropped(to: extent)

    case .border(let hex, let width, let cornerRadius):
        // Stroked outline — no built-in CIFilter. Materialize + re-wrap.
        guard let cg = SharedCIContext.context.createCGImage(ci, from: extent) else { return ci }
        let bordered = applyBorder(
            to: platformImage(from: cg, size: size),
            hex: hex, width: width, cornerRadius: cornerRadius
        )
        guard let borderedCG = cgImage(from: bordered) else { return ci }
        return CIImage(cgImage: borderedCG).cropped(to: extent)
    }
}

/// Bridges `HarnessKitTransform`'s `ProgressiveBlurDirection` enum
/// into the enum `applyMetalProgressiveBlur` (and the underlying
/// Metal shader's integer `direction` param) expects. Mapping
/// matches the ladder in `blur_ci.metalsrc`'s `mapRadius` — 0=down,
/// 1=up, 2=right, 3=left — the same encoding Framely pushes into
/// ForkedGlur's shader on the preview side.
private func metalBlurDirection(from dir: ProgressiveBlurDirection) -> MetalBlurDirection {
    switch dir {
    case .topToBottom: return .down
    case .bottomToTop: return .up
    case .leftToRight: return .right
    case .rightToLeft: return .left
    }
}

func gaussianBlur(_ ci: CIImage, radius: Double) -> CIImage {
    if #available(macOS 12.0, iOS 15.0, visionOS 1.0, *) {
        let f = CIFilter.gaussianBlur()
        f.inputImage = ci
        f.radius = Float(radius)
        return f.outputImage ?? ci
    } else {
        guard let f = CIFilter(name: "CIGaussianBlur") else { return ci }
        f.setValue(ci, forKey: kCIInputImageKey)
        f.setValue(radius, forKey: kCIInputRadiusKey)
        return f.outputImage ?? ci
    }
}

func blendWithMaskCI(
    sharp: CIImage,
    background: CIImage,
    mask: CIImage,
    extent: CGRect
) -> CIImage {
    if #available(macOS 12.0, iOS 15.0, visionOS 1.0, *) {
        let blend = CIFilter.blendWithMask()
        blend.inputImage = sharp
        blend.backgroundImage = background
        blend.maskImage = mask
        return (blend.outputImage ?? sharp).cropped(to: extent)
    } else {
        guard let f = CIFilter(name: "CIBlendWithMask") else { return sharp }
        f.setValue(sharp, forKey: kCIInputImageKey)
        f.setValue(background, forKey: kCIInputBackgroundImageKey)
        f.setValue(mask, forKey: kCIInputMaskImageKey)
        return (f.outputImage ?? sharp).cropped(to: extent)
    }
}

/// CIImage-wrapped gradient mask routed through `CIImageCache` so
/// same-key renders across layers and batched export runs dedup.
/// Uses the CG-based renderer underneath to keep pixel output
/// bit-for-bit identical.
func gradientMaskCI(size: CGSize, direction: ProgressiveBlurDirection, start: Double = 0, end: Double = 1) -> CIImage? {
    CIImageCache.linearGradientMask(size: size, direction: direction, start: start, end: end)
}

/// Renders the linear mask used by `.progressiveFade` and
/// `.progressiveBlur`. `start`/`end` are the two SwiftUI-style
/// gradient-stop locations along the fade path: the "opaque" stop
/// sits at `start` and the "transparent" stop at `end`, with the
/// endpoints extended by `.drawsBeforeStartLocation` /
/// `.drawsAfterEndLocation` so the solid ends continue to the rect's
/// edges. Values outside `[0, 1]` are accepted and produce a
/// softer / harder fade in exactly the same way the SwiftUI preview
/// does (Framely's `CanvasLayerEffectsModifier` uses matching stop
/// locations).
func createGradientMask(size: CGSize, direction: ProgressiveBlurDirection, start: Double = 0, end: Double = 1) -> PlatformImage {
    createImage(size: size) { ctx in
        let rect = CGRect(origin: .zero, size: size)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let white = CGColor(red: 1, green: 1, blue: 1, alpha: 1)
        let black = CGColor(red: 0, green: 0, blue: 0, alpha: 1)

        // Path endpoints follow the direction name exactly (e.g.
        // `.bottomToTop` goes from bottom to top), matching the SwiftUI
        // preview's `UnitPoint` convention in
        // `CanvasLayerEffectsModifier.gradientMask`. Path is in Y-up CG
        // space (`createImage` normalizes both platforms to Y-up), so
        // `maxY` is visually top and `minY` visually bottom. Colors are
        // white→black on every direction: white = solid (opaque in the
        // CI mask), black = transparent. `start`/`end` are the
        // gradient-stop locations along that path — identical semantics
        // to SwiftUI's `Gradient.Stop.location` so partial-range fades
        // (e.g. `start: 0.5`) render the same on preview and export.
        let (startPt, endPt): (CGPoint, CGPoint) = switch direction {
        case .topToBottom: (CGPoint(x: rect.midX, y: rect.maxY), CGPoint(x: rect.midX, y: rect.minY))
        case .bottomToTop: (CGPoint(x: rect.midX, y: rect.minY), CGPoint(x: rect.midX, y: rect.maxY))
        case .leftToRight: (CGPoint(x: rect.minX, y: rect.midY), CGPoint(x: rect.maxX, y: rect.midY))
        case .rightToLeft: (CGPoint(x: rect.maxX, y: rect.midY), CGPoint(x: rect.minX, y: rect.midY))
        }

        let locations: [CGFloat] = [CGFloat(start), CGFloat(end)]
        if let gradient = CGGradient(colorsSpace: colorSpace, colors: [white, black] as CFArray, locations: locations) {
            ctx.drawLinearGradient(gradient, start: startPt, end: endPt, options: [.drawsBeforeStartLocation, .drawsAfterEndLocation])
        }
    }
}

func applyCanvasCornerRadius(to image: PlatformImage, radius: Double) -> PlatformImage {
    let size = imageSize(image)
    return createImage(size: size) { ctx in
        let rect = CGRect(origin: .zero, size: size)
        let path = continuousRoundedRectPath(rect: rect, radius: CGFloat(radius))
        ctx.addPath(path)
        ctx.clip()
        drawImageInContext(image, in: rect, context: ctx)
    }
}

/// Fills a rounded-rect background behind `content` and composites the
/// content on top. Used when a `CanvasLayer` carries a `backgroundColor`.
///
/// When `content` has halo padding (blur overflow), `bgRect` locates the
/// layer's authored frame within the padded bitmap — the fill stays
/// confined to the frame area while the halo extends past it. For the
/// no-padding case the default `bgRect = CGRect(origin: .zero, size:
/// size)` keeps the original behavior.
func applyBackgroundColor(
    behind content: PlatformImage,
    hex: String,
    cornerRadius: Double,
    size: CGSize,
    bgRect: CGRect? = nil
) -> PlatformImage {
    let color = platformColor(hex: hex, opacity: 1.0)
    let fillRect = bgRect ?? CGRect(origin: .zero, size: size)
    return createImage(size: size) { ctx in
        // Fill background.
        if cornerRadius > 0 {
            let path = continuousRoundedRectPath(rect: fillRect, radius: CGFloat(cornerRadius))
            ctx.addPath(path)
            ctx.setFillColor(color.cgColor)
            ctx.fillPath()
        } else {
            ctx.setFillColor(color.cgColor)
            ctx.fill(fillRect)
        }
        // Composite content on top.
        drawImageInContext(content, in: CGRect(origin: .zero, size: size), context: ctx)
    }
}

// MARK: - Halo padding

/// Maximum blur tail in pixels produced by the layer's effects. Used to
/// pre-pad the content bitmap so progressive/plain blurs can extend past
/// the layer's frame instead of being clipped at the bitmap edge.
/// `3σ` captures ~99.7% of Gaussian energy — a reasonable cutoff where
/// additional extension would be imperceptible.
func blurHaloPadding(for effects: [CanvasLayerEffect]) -> CGFloat {
    var maxRadius: Double = 0
    for effect in effects {
        switch effect {
        case .blur(let r): maxRadius = max(maxRadius, r)
        case .progressiveBlur(let r, _, _, _): maxRadius = max(maxRadius, r)
        default: break
        }
    }
    return CGFloat(maxRadius * 3)
}

/// Returns a new image of size `frameSize + 2 × halo` with `image`
/// drawn centered and transparent padding around it. No-op (returns
/// the input) when `halo == 0`.
func padImageWithHalo(
    _ image: PlatformImage,
    frameSize: CGSize,
    halo: CGFloat
) -> PlatformImage {
    guard halo > 0 else { return image }
    let padded = CGSize(
        width: frameSize.width + 2 * halo,
        height: frameSize.height + 2 * halo
    )
    return createImage(size: padded) { ctx in
        drawImageInContext(
            image,
            in: CGRect(x: halo, y: halo, width: frameSize.width, height: frameSize.height),
            context: ctx
        )
    }
}

func applyBorder(to image: PlatformImage, hex: String, width: Double, cornerRadius: Double) -> PlatformImage {
    let size = imageSize(image)
    return createImage(size: size) { ctx in
        let rect = CGRect(origin: .zero, size: size)
        drawImageInContext(image, in: rect, context: ctx)
        let inset = CGFloat(width) / 2
        let borderRect = rect.insetBy(dx: inset, dy: inset)
        let path = continuousRoundedRectPath(rect: borderRect, radius: CGFloat(cornerRadius))
        ctx.addPath(path)
        ctx.setLineWidth(CGFloat(width))
        ctx.setStrokeColor(platformColor(hex: hex, opacity: 1.0).cgColor)
        ctx.strokePath()
    }
}

// MARK: - Layer Compositing

func compositeLayer(
    content: PlatformImage,
    onto canvas: PlatformImage,
    frame: CGRect,
    rotation: Double,
    opacity: Double,
    dropShadows: [CanvasLayerShadow],
    halo: CGFloat = 0
) -> PlatformImage {
    let canvasSize = imageSize(canvas)
    // When `content` carries halo padding (blur overflow), draw it into
    // a rect centered on `frame` but expanded by `halo` on every side so
    // the blurred pixels land outside the layer's authored rect — same
    // as the SwiftUI preview's overlay-without-bounding-frame trick.
    let contentRect = halo > 0 ? frame.insetBy(dx: -halo, dy: -halo) : frame
    return createImage(size: canvasSize) { ctx in
        drawImageInContext(canvas, in: CGRect(origin: .zero, size: canvasSize), context: ctx)

        ctx.saveGState()

        if rotation != 0 {
            let center = CGPoint(x: frame.midX, y: frame.midY)
            ctx.translateBy(x: center.x, y: center.y)
            ctx.rotate(by: CGFloat(rotation) * .pi / 180)
            ctx.translateBy(x: -center.x, y: -center.y)
        }

        for shadow in dropShadows {
            let refDim = min(frame.width, frame.height)
            ctx.setShadow(
                offset: CGSize(width: CGFloat(shadow.offsetX) * frame.width / 2,
                               height: -CGFloat(shadow.offsetY) * frame.height / 2),
                blur: CGFloat(shadow.blur) * refDim,
                color: platformColor(hex: shadow.color, opacity: shadow.opacity).cgColor
            )
        }

        drawImageInContext(content, in: contentRect, context: ctx, opacity: CGFloat(opacity))

        ctx.restoreGState()
    }
}

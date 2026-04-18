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
func applyCanvasEffects(to image: PlatformImage, effects: [CanvasLayerEffect]) -> PlatformImage {
    guard !effects.isEmpty else { return image }
    guard let input = cgImage(from: image) else { return image }

    var ci: CIImage = CIImage(cgImage: input)
    let extent = ci.extent
    let size = imageSize(image)

    for effect in effects {
        ci = applyCanvasEffect(to: ci, effect: effect, extent: extent, size: size)
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
    size: CGSize
) -> CIImage {
    switch effect {
    case .blur(let radius):
        guard radius > 0 else { return ci }
        return gaussianBlur(ci, radius: radius).cropped(to: extent)

    case .progressiveBlur(let radius, let direction, _, _):
        guard radius > 0 else { return ci }
        // Materialize the blurred pyramid to 8-bit CGImage before the
        // blend. Fusing `gaussianBlur → blendWithMask` in CIImage space
        // keeps float4 through the chain, which diverges from the
        // bitmap round-trip baseline by up to ±2 per channel at blur
        // boundaries — enough to break Goldens. Cost: one canvas-sized
        // CGImage alloc per progressiveBlur (same as before; what we
        // saved is the sharp-side round-trip + the mask CGImage
        // round-trip on subsequent effects).
        let blurredCI = gaussianBlur(ci, radius: radius).cropped(to: extent)
        guard let blurredCG = SharedCIContext.context.createCGImage(blurredCI, from: extent) else {
            return ci
        }
        let blurredQuantized = CIImage(cgImage: blurredCG)
        guard let mask = gradientMaskCI(size: size, direction: direction) else { return ci }
        return blendWithMaskCI(sharp: ci, background: blurredQuantized, mask: mask, extent: extent)

    case .progressiveFade(let direction, _, _):
        let transparent = CIImage(color: CIColor.clear).cropped(to: extent)
        guard let mask = gradientMaskCI(size: size, direction: direction) else { return ci }
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
func gradientMaskCI(size: CGSize, direction: ProgressiveBlurDirection) -> CIImage? {
    CIImageCache.linearGradientMask(size: size, direction: direction)
}

func createGradientMask(size: CGSize, direction: ProgressiveBlurDirection) -> PlatformImage {
    createImage(size: size) { ctx in
        let rect = CGRect(origin: .zero, size: size)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let white = CGColor(red: 1, green: 1, blue: 1, alpha: 1)
        let black = CGColor(red: 0, green: 0, blue: 0, alpha: 1)

        let (startColor, endColor, start, end): (CGColor, CGColor, CGPoint, CGPoint) = switch direction {
        case .topToBottom: (white, black, CGPoint(x: rect.midX, y: rect.maxY), CGPoint(x: rect.midX, y: rect.minY))
        case .bottomToTop: (black, white, CGPoint(x: rect.midX, y: rect.maxY), CGPoint(x: rect.midX, y: rect.minY))
        case .leftToRight: (white, black, CGPoint(x: rect.minX, y: rect.midY), CGPoint(x: rect.maxX, y: rect.midY))
        case .rightToLeft: (black, white, CGPoint(x: rect.minX, y: rect.midY), CGPoint(x: rect.maxX, y: rect.midY))
        }

        if let gradient = CGGradient(colorsSpace: colorSpace, colors: [startColor, endColor] as CFArray, locations: [0, 1]) {
            ctx.drawLinearGradient(gradient, start: start, end: end, options: [.drawsBeforeStartLocation, .drawsAfterEndLocation])
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
func applyBackgroundColor(
    behind content: PlatformImage,
    hex: String,
    cornerRadius: Double,
    size: CGSize
) -> PlatformImage {
    let color = platformColor(hex: hex, opacity: 1.0)
    return createImage(size: size) { ctx in
        // Fill background.
        if cornerRadius > 0 {
            let path = continuousRoundedRectPath(rect: CGRect(origin: .zero, size: size), radius: CGFloat(cornerRadius))
            ctx.addPath(path)
            ctx.setFillColor(color.cgColor)
            ctx.fillPath()
        } else {
            ctx.setFillColor(color.cgColor)
            ctx.fill(CGRect(origin: .zero, size: size))
        }
        // Composite content on top.
        drawImageInContext(content, in: CGRect(origin: .zero, size: size), context: ctx)
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
    dropShadows: [CanvasLayerShadow]
) -> PlatformImage {
    let canvasSize = imageSize(canvas)
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

        drawImageInContext(content, in: frame, context: ctx, opacity: CGFloat(opacity))

        ctx.restoreGState()
    }
}

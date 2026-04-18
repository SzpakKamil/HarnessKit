import Foundation
import CoreGraphics
import ImageIO
import HarnessKitScreenshots

// MARK: - Downsample budget

/// Pixel-size budget for `platformImage(contentsOf:maxPixelSize:)` when
/// loading canvas image content. Uses the frame's long-edge pixel dimension
/// × 2 (Retina safety) so we never force an upscale pass in the subsequent
/// `scale`-multiplied draw. For practical canvases the budget is 1–4k, so
/// a user-supplied 8k photo is decoded at 2–8k instead of 8k full-res —
/// saving tens of MB without visible quality loss.
func canvasLayerMaxPixelSize(_ frame: CGRect) -> Int {
    let longEdge = max(frame.width, frame.height)
    guard longEdge > 0 else { return 0 }
    return Int(ceil(longEdge * 2))
}

// MARK: - Shape Rendering

func renderShape(_ style: CanvasShapeStyle, frame: CGRect, cornerRadius: Double = 0) -> PlatformImage {
    let size = frame.size
    return createImage(size: size) { ctx in
        let rect = CGRect(origin: .zero, size: size)

        // Inline continuous corner-radius clip — saves one extra
        // full-layer bitmap vs. the post-hoc `applyCanvasCornerRadius`
        // pass. Identical output because it uses the same
        // `continuousRoundedRectPath` (SwiftUI
        // `RoundedRectangle(style: .continuous)`).
        if cornerRadius > 0 {
            let cornerPath = continuousRoundedRectPath(rect: rect, radius: CGFloat(cornerRadius))
            ctx.addPath(cornerPath)
            ctx.clip()
        }

        // SVG renders itself — skip the path-based fill/stroke pipeline.
        // Direct CGImageSource path avoids NSImage's TIFF round-trip
        // (same rationale as `_roundedPNG`'s direct path): decoding
        // through `NSImage(data:)` materializes an uncompressed bitmap
        // representation behind the NSImage which is then discarded
        // after the `cgImage(forProposedRect:)` call — wasted ~5–15 MB
        // per SVG layer. CGImageSource gives us the CGImage directly.
        //
        // Leak safety: CGImageSource is CF-bridged and released by ARC
        // when `source` / `cgImage` go out of scope. The size-limit
        // option (`kCGImageSourceThumbnailMaxPixelSize`) bounds decode
        // memory when a caller supplies a huge SVG for a small layer.
        if case .customSVG(let svgString) = style.path {
            if let data = svgString.data(using: .utf8) as CFData?,
               let source = CGImageSourceCreateWithData(data, nil) {
                let maxPixel = Int(ceil(max(rect.width, rect.height) * 2))
                let options: [CFString: Any] = [
                    kCGImageSourceShouldCache: false,
                    kCGImageSourceCreateThumbnailFromImageAlways: true,
                    kCGImageSourceThumbnailMaxPixelSize: maxPixel
                ]
                if let cgImage = CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary) {
                    ctx.draw(cgImage, in: rect)
                }
            }
            return
        }

        // Build CGPath for the shape
        let shapePath: CGPath
        switch style.path {
        case .rectangle(let cr):
            shapePath = continuousRoundedRectPath(rect: rect, radius: CGFloat(cr))
        case .ellipse:
            shapePath = CGPath(ellipseIn: rect, transform: nil)
        case .roundedRectangle(let tl, let tr, let bl, let br):
            shapePath = roundedRectCGPath(rect: rect, topLeft: tl, topRight: tr, bottomLeft: bl, bottomRight: br)
        case .line(let sx, let sy, let ex, let ey):
            let p = CGMutablePath()
            p.move(to: CGPoint(x: rect.width * CGFloat(sx), y: rect.height * CGFloat(sy)))
            p.addLine(to: CGPoint(x: rect.width * CGFloat(ex), y: rect.height * CGFloat(ey)))
            shapePath = p
        case .customSVG:
            return  // handled above; unreachable but satisfies exhaustiveness
        }

        if let fill = style.fill {
            switch fill {
            case .solid(let hex, let opacity):
                ctx.addPath(shapePath)
                ctx.setFillColor(platformColor(hex: hex, opacity: opacity).cgColor)
                ctx.fillPath()
            case .linearGradient(let startHex, let endHex, let angle, let opacity):
                ctx.saveGState()
                ctx.addPath(shapePath)
                ctx.clip()
                drawLinearGradient(in: ctx, rect: rect,
                                   startColor: platformColor(hex: startHex, opacity: opacity),
                                   endColor: platformColor(hex: endHex, opacity: opacity),
                                   angle: CGFloat(angle))
                ctx.restoreGState()
            case .radialGradient(let centerHex, let edgeHex, let opacity):
                ctx.saveGState()
                ctx.addPath(shapePath)
                ctx.clip()
                drawRadialGradient(in: ctx, rect: rect,
                                   centerColor: platformColor(hex: centerHex, opacity: opacity),
                                   edgeColor: platformColor(hex: edgeHex, opacity: opacity))
                ctx.restoreGState()
            case .image(let imgPath, let scale, let offsetX, let offsetY):
                // Same Retina-safe downsample as the image-layer path: a
                // huge asset used as a shape fill still only needs to
                // cover the shape's pixel box.
                if let img = platformImage(contentsOfFile: imgPath, maxPixelSize: canvasLayerMaxPixelSize(frame)) {
                    ctx.saveGState()
                    ctx.addPath(shapePath)
                    ctx.clip()
                    let srcSize = imageSize(img)
                    guard srcSize.width > 0, srcSize.height > 0 else { break }
                    let scaleX = rect.width / srcSize.width
                    let scaleY = rect.height / srcSize.height
                    let baseScale = max(scaleX, scaleY) * CGFloat(scale)
                    let drawW = srcSize.width * baseScale
                    let drawH = srcSize.height * baseScale
                    let drawX = (rect.width - drawW) / 2 + CGFloat(offsetX) * rect.width
                    let drawY = (rect.height - drawH) / 2 + CGFloat(offsetY) * rect.height
                    drawImageInContext(img, in: CGRect(x: drawX, y: drawY, width: drawW, height: drawH), context: ctx)
                    ctx.restoreGState()
                }
            }
        }
        if let strokeHex = style.strokeColor {
            ctx.addPath(shapePath)
            ctx.setStrokeColor(platformColor(hex: strokeHex, opacity: style.strokeOpacity).cgColor)
            ctx.setLineWidth(CGFloat(style.strokeWidth))
            ctx.strokePath()
        }
    }
}

func roundedRectCGPath(rect: CGRect, topLeft: Double, topRight: Double, bottomLeft: Double, bottomRight: Double) -> CGPath {
    let tl = CGFloat(topLeft), tr = CGFloat(topRight), bl = CGFloat(bottomLeft), br = CGFloat(bottomRight)
    let path = CGMutablePath()
    path.move(to: CGPoint(x: rect.minX + bl, y: rect.minY))
    path.addLine(to: CGPoint(x: rect.maxX - br, y: rect.minY))
    path.addArc(center: CGPoint(x: rect.maxX - br, y: rect.minY + br), radius: br, startAngle: -.pi / 2, endAngle: 0, clockwise: false)
    path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - tr))
    path.addArc(center: CGPoint(x: rect.maxX - tr, y: rect.maxY - tr), radius: tr, startAngle: 0, endAngle: .pi / 2, clockwise: false)
    path.addLine(to: CGPoint(x: rect.minX + tl, y: rect.maxY))
    path.addArc(center: CGPoint(x: rect.minX + tl, y: rect.maxY - tl), radius: tl, startAngle: .pi / 2, endAngle: .pi, clockwise: false)
    path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + bl))
    path.addArc(center: CGPoint(x: rect.minX + bl, y: rect.minY + bl), radius: bl, startAngle: .pi, endAngle: 3 * .pi / 2, clockwise: false)
    path.closeSubpath()
    return path
}

// MARK: - Continuous corner-radius path

/// Returns a rounded-rect `CGPath` using Apple's continuous-curve
/// (superellipse/"squircle") algorithm, matching SwiftUI's
/// `RoundedRectangle(cornerRadius:style:.continuous)`.
/// Cached via `ContinuousPathCache` so repeated renders dedup.
func continuousRoundedRectPath(rect: CGRect, radius: CGFloat) -> CGPath {
    ContinuousPathCache.path(rect: rect, radius: radius)
}

// MARK: - Image Content Rendering

func renderImageContent(_ image: PlatformImage, frame: CGRect, scale: Double, offsetX: Double, offsetY: Double, contentMode: CanvasImageContentMode, cornerRadius: Double = 0) -> PlatformImage {
    let size = frame.size
    return createImage(size: size) { ctx in
        // Inline the continuous corner-radius clip. Saves one full
        // layer-sized allocation vs. `applyCanvasCornerRadius` on a
        // freshly-rendered bitmap. Same `continuousRoundedRectPath` is
        // used — bit-for-bit identical to the post-hoc clip.
        if cornerRadius > 0 {
            let cornerPath = continuousRoundedRectPath(
                rect: CGRect(origin: .zero, size: size),
                radius: CGFloat(cornerRadius)
            )
            ctx.addPath(cornerPath)
            ctx.clip()
        }

        let srcSize = imageSize(image)
        guard srcSize.width > 0, srcSize.height > 0 else { return }
        let scaleX = size.width / srcSize.width
        let scaleY = size.height / srcSize.height
        // `.fit` shrinks until both axes are inside the frame (no
        // clipping required, and the unmatched axis shows empty space).
        // `.fill` grows until both axes cover the frame and overflowing
        // pixels are cropped to the frame rect by the clip below — without
        // the clip the overflow would leak out of the layer's authored
        // bounds when composited later.
        let baseScale: CGFloat
        switch contentMode {
        case .fit:  baseScale = min(scaleX, scaleY) * CGFloat(scale)
        case .fill: baseScale = max(scaleX, scaleY) * CGFloat(scale)
        }
        let drawW = srcSize.width * baseScale
        let drawH = srcSize.height * baseScale
        let drawX = (size.width - drawW) / 2 + CGFloat(offsetX) * size.width
        let drawY = (size.height - drawH) / 2 + CGFloat(offsetY) * size.height
        if contentMode == .fill {
            ctx.saveGState()
            ctx.clip(to: CGRect(origin: .zero, size: size))
        }
        drawImageInContext(image, in: CGRect(x: drawX, y: drawY, width: drawW, height: drawH), context: ctx)
        if contentMode == .fill {
            ctx.restoreGState()
        }
    }
}

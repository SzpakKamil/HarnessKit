import Foundation
import CoreGraphics
import HarnessKitScreenshots
#if canImport(AppKit)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

// MARK: - Text Rendering

func renderText(_ string: String, style: CanvasTextStyle, frame: CGRect) -> PlatformImage {
    let size = frame.size
    return createImage(size: size, flipped: true) { ctx in
        let font = resolveFont(family: style.fontFamily, size: CGFloat(style.fontSize), weight: style.fontWeight, italic: style.isItalic)
        let color = platformColor(hex: style.color, opacity: 1.0)

        #if canImport(AppKit)
        let alignment: NSTextAlignment = switch style.alignment {
        case .left: .left
        case .center: .center
        case .right: .right
        }
        let paragraphStyle = TextRenderCache.paragraphStyle(
            alignment: alignment,
            lineSpacingPx: CGFloat(style.lineSpacing - 1.0) * font.pointSize
        )

        var attributes: [NSAttributedString.Key: Any] = [
            .font: font, .foregroundColor: color, .paragraphStyle: paragraphStyle
        ]
        if style.letterSpacing != 0 { attributes[.kern] = CGFloat(style.letterSpacing) }
        if let shadow = style.shadow {
            attributes[.shadow] = TextRenderCache.shadow(
                colorHex: shadow.color, opacity: shadow.opacity,
                blur: shadow.blur, offsetX: shadow.offsetX, offsetY: shadow.offsetY,
                invertY: true  // AppKit text: positive Y is up, source offsetY is UI-down
            )
        }
        let attrString = NSAttributedString(string: string, attributes: attributes)
        // `attrString.draw(in:)` places the first line's line-box TOP
        // at the draw rect's top, which means the first baseline sits
        // at `font.ascender` below the rect top and the cap tops at
        // `ascender - capHeight` below that — i.e. the font's natural
        // "shoulder" of empty space sits *inside* the layer frame.
        //
        // SwiftUI's `Text` on macOS positions glyphs tighter: the
        // rendered cap tops land visually flush with the Text frame's
        // top edge, so the interactive canvas shows text higher than
        // the exporter's draw-at-top result. To match, we shift the
        // draw rect UPWARD by that shoulder (`ascender - capHeight`)
        // so the ink starts at the rect top instead of the line-box
        // top. The line-box itself extends above the image into
        // negative y, but only empty leading space lives there — no
        // glyphs are clipped.
        let topInset = max(0, font.ascender - font.capHeight)
        // Vertical alignment: slack = authored height minus the
        // text's visible (cap-top-to-line-bottom) height. Without
        // subtracting `topInset` the slack would include the shoulder
        // we just hid, and center/bottom alignment would drift down
        // by that amount.
        let measuredRect = attrString.boundingRect(
            with: CGSize(width: size.width, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading]
        )
        let visibleHeight = max(0, measuredRect.height - topInset)
        let slack = max(0, size.height - visibleHeight)
        let yOffset: CGFloat = switch style.verticalAlignment {
        case .top: 0
        case .center: slack / 2
        case .bottom: slack
        }
        attrString.draw(in: CGRect(
            x: 0,
            y: yOffset - topInset,
            width: size.width,
            height: size.height - yOffset + topInset
        ))
        #else
        let alignment: NSTextAlignment = switch style.alignment {
        case .left: .left
        case .center: .center
        case .right: .right
        }
        let paragraphStyle = TextRenderCache.paragraphStyle(
            alignment: alignment,
            lineSpacingPx: CGFloat(style.lineSpacing - 1.0) * font.pointSize
        )

        var attributes: [NSAttributedString.Key: Any] = [
            .font: font, .foregroundColor: color, .paragraphStyle: paragraphStyle
        ]
        if style.letterSpacing != 0 { attributes[.kern] = CGFloat(style.letterSpacing) }
        if let shadow = style.shadow {
            attributes[.shadow] = TextRenderCache.shadow(
                colorHex: shadow.color, opacity: shadow.opacity,
                blur: shadow.blur, offsetX: shadow.offsetX, offsetY: shadow.offsetY,
                invertY: true
            )
        }

        // Push UIKit graphics context for attributed string drawing.
        // `defer` pairs the pop with the push so any future early-return
        // (e.g. layout math that bails on NaN / non-finite) can't leak
        // a pushed context. UIGraphicsPushContext maintains an internal
        // stack — an unbalanced push is a real leak that survives the
        // enclosing autoreleasepool.
        UIGraphicsPushContext(ctx)
        defer { UIGraphicsPopContext() }
        let attrString = NSAttributedString(string: string, attributes: attributes)
        // Same cap-top alignment + vertical-alignment slack as the
        // AppKit branch — see that block's comment for the full
        // rationale.
        let topInset = max(0, font.ascender - font.capHeight)
        let measuredRect = attrString.boundingRect(
            with: CGSize(width: size.width, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil
        )
        let visibleHeight = max(0, measuredRect.height - topInset)
        let slack = max(0, size.height - visibleHeight)
        let yOffset: CGFloat = switch style.verticalAlignment {
        case .top: 0
        case .center: slack / 2
        case .bottom: slack
        }
        attrString.draw(in: CGRect(
            x: 0,
            y: yOffset - topInset,
            width: size.width,
            height: size.height - yOffset + topInset
        ))
        #endif
    }
}

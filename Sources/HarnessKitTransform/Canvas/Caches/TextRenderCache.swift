// Bounded caches for text-rendering intermediates that `renderText`
// would otherwise allocate per layer:
// - `NSParagraphStyle` (immutable — `NSMutableParagraphStyle.copy()`)
//   keyed by `(alignment, lineSpacingMultiplier, fontPointSize)`.
// - `NSShadow` keyed by `(color, opacity, blur, offsetX, offsetY)`.
//   Returned as a fresh `.copy()` on every hit so callers mutating
//   the returned shadow (even accidentally) can't corrupt the cache.
//
// A 20-text-layer canvas was allocating 60+ small Foundation objects;
// most canvases reuse the same few styles (e.g. "body 24pt left-aligned")
// across many layers so the cache hit rate is high.
//
// Leak safety:
// - Fixed capacity: FIFO-16 per cache. `map.count` can never exceed
//   `maxEntries`.
// - `os_unfair_lock_s`-gated. Locks held only for dict operations;
//   builders run outside the lock so concurrent misses on different
//   keys don't serialize.
// - Hooks into `HarnessKitCatalogue.invalidateCaches()` via `clear()`.
// - Paragraph styles are stored as **immutable** `NSParagraphStyle`
//   (produced by `NSMutableParagraphStyle.copy()`) so aliasing
//   across callers is safe — `attributes[.paragraphStyle] = cached`
//   can't be mutated later.
// - Shadows are returned as a fresh `.copy()` on every hit to
//   guarantee per-call isolation even though the cache holds the
//   canonical template.
//

import Foundation
import CoreGraphics
import os.lock

#if canImport(AppKit)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

enum TextRenderCache {
    private static let maxEntries = 16

    // MARK: - Paragraph style

    private struct ParagraphKey: Hashable {
        let alignmentRaw: Int          // NSTextAlignment.rawValue
        let lineSpacingPxQ: Int32      // (lineSpacingMultiplier - 1) * fontPointSize × 100
    }

    nonisolated(unsafe) private static var _paraLock = os_unfair_lock_s()
    nonisolated(unsafe) private static var paragraphMap: [ParagraphKey: NSParagraphStyle] = [:]
    nonisolated(unsafe) private static var paragraphOrder: [ParagraphKey] = []

    static func paragraphStyle(
        alignment: NSTextAlignment,
        lineSpacingPx: CGFloat
    ) -> NSParagraphStyle {
        let key = ParagraphKey(
            alignmentRaw: alignment.rawValue,
            lineSpacingPxQ: Int32((lineSpacingPx * 100).rounded())
        )

        os_unfair_lock_lock(&_paraLock)
        if let hit = paragraphMap[key] {
            os_unfair_lock_unlock(&_paraLock)
            return hit
        }
        os_unfair_lock_unlock(&_paraLock)

        // Build outside the lock.
        let mutable = NSMutableParagraphStyle()
        mutable.alignment = alignment
        mutable.lineSpacing = lineSpacingPx
        let immutable = (mutable.copy() as? NSParagraphStyle) ?? mutable

        os_unfair_lock_lock(&_paraLock)
        defer { os_unfair_lock_unlock(&_paraLock) }
        if let racing = paragraphMap[key] {
            return racing
        }
        paragraphMap[key] = immutable
        paragraphOrder.append(key)
        if paragraphOrder.count > maxEntries {
            let evicted = paragraphOrder.removeFirst()
            paragraphMap.removeValue(forKey: evicted)
        }
        return immutable
    }

    // MARK: - NSShadow

    private struct ShadowKey: Hashable {
        let colorHex: String
        let opacityQ: Int32        // × 10000
        let blurQ: Int32           // × 100
        let offsetXQ: Int32        // × 100
        let offsetYQ: Int32        // × 100
    }

    nonisolated(unsafe) private static var _shadowLock = os_unfair_lock_s()
    nonisolated(unsafe) private static var shadowMap: [ShadowKey: NSShadow] = [:]
    nonisolated(unsafe) private static var shadowOrder: [ShadowKey] = []

    /// Returns an `NSShadow` configured for the given parameters. Output
    /// is a **fresh copy** of the cached template so callers who mutate
    /// it (e.g. setting a different offset later) don't corrupt the
    /// shared entry.
    ///
    /// `offsetYInverted` should be `true` when the caller's coordinate
    /// system needs NSShadow's upward-positive-Y inverted (UIKit), and
    /// `false` when the caller already accounts for it (AppKit on text
    /// layers uses negative Y directly).
    static func shadow(
        colorHex: String,
        opacity: Double,
        blur: Double,
        offsetX: Double,
        offsetY: Double,
        invertY: Bool
    ) -> NSShadow {
        let signedOffsetY = invertY ? -offsetY : offsetY
        let key = ShadowKey(
            colorHex: colorHex,
            opacityQ: Int32((opacity * 10000).rounded()),
            blurQ: Int32((blur * 100).rounded()),
            offsetXQ: Int32((offsetX * 100).rounded()),
            offsetYQ: Int32((signedOffsetY * 100).rounded())
        )

        os_unfair_lock_lock(&_shadowLock)
        if let template = shadowMap[key] {
            os_unfair_lock_unlock(&_shadowLock)
            return (template.copy() as? NSShadow) ?? template
        }
        os_unfair_lock_unlock(&_shadowLock)

        let template = NSShadow()
        template.shadowColor = platformColor(hex: colorHex, opacity: opacity)
        template.shadowBlurRadius = CGFloat(blur)
        #if canImport(AppKit)
        template.shadowOffset = NSSize(width: offsetX, height: signedOffsetY)
        #else
        template.shadowOffset = CGSize(width: offsetX, height: signedOffsetY)
        #endif

        os_unfair_lock_lock(&_shadowLock)
        defer { os_unfair_lock_unlock(&_shadowLock) }
        if let racing = shadowMap[key] {
            return (racing.copy() as? NSShadow) ?? racing
        }
        shadowMap[key] = template
        shadowOrder.append(key)
        if shadowOrder.count > maxEntries {
            let evicted = shadowOrder.removeFirst()
            shadowMap.removeValue(forKey: evicted)
        }
        return (template.copy() as? NSShadow) ?? template
    }

    // MARK: - Clear / stats

    static func clear() {
        os_unfair_lock_lock(&_paraLock)
        paragraphMap.removeAll(keepingCapacity: false)
        paragraphOrder.removeAll(keepingCapacity: false)
        os_unfair_lock_unlock(&_paraLock)

        os_unfair_lock_lock(&_shadowLock)
        shadowMap.removeAll(keepingCapacity: false)
        shadowOrder.removeAll(keepingCapacity: false)
        os_unfair_lock_unlock(&_shadowLock)
    }

    /// Test-only: count of live paragraph-style entries.
    static var paragraphCacheSize: Int {
        os_unfair_lock_lock(&_paraLock); defer { os_unfair_lock_unlock(&_paraLock) }
        return paragraphMap.count
    }

    /// Test-only: count of live shadow entries.
    static var shadowCacheSize: Int {
        os_unfair_lock_lock(&_shadowLock); defer { os_unfair_lock_unlock(&_shadowLock) }
        return shadowMap.count
    }
}

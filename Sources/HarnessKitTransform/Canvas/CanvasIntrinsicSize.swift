//
//  CanvasIntrinsicSize.swift
//  HarnessKitTransform
//
//  Pure-value intrinsic sizing rules for canvas layer content. The
//  interactive canvas, the inspector, and the exporter all import
//  these so every consumer agrees on what "intrinsic" means per
//  content kind without each re-implementing the conversion.
//
//  Tree-aware helpers (anything that walks a `LayerNode` / `RowNode`
//  graph) stay in Framely — this file is strictly `CanvasLayerContent`
//  → `CGSize`.
//
//  Special rule: device bezels ALWAYS derive from
//  `CanvasDeviceConfig.nativeWidth/Height × canvasPointsPerPixel`.
//  Resizing a parent frame must not stretch a bezel.
//

import Foundation
import CoreGraphics

/// Canvas-points per native device pixel. A 1290-px-wide iPhone screen
/// becomes 645 canvas points wide.
public let canvasPointsPerPixel: CGFloat = 0.5

/// Fallback intrinsic sizes for non-device leaves when a layer has no
/// authored size and no other source (text measurement, image pixels)
/// is available.
public enum CanvasIntrinsicFallback {
    public static let text  = CGSize(width: 120, height: 40)
    public static let shape = CGSize(width: 120, height: 120)
    public static let image = CGSize(width: 200, height: 200)
    public static let frame = CGSize(width: 800, height: 600)
}

/// Intrinsic (fallback) size for a content kind when the layer has no
/// authored size. Text layers' true intrinsic size depends on string +
/// style and is decided at layout time — this returns a placeholder
/// only for cases where a concrete number is required synchronously.
public func intrinsicSize(for content: CanvasLayerContent?) -> CGSize {
    switch content {
    case .none:
        return CanvasIntrinsicFallback.frame
    case .device(let config):
        // Zero for platforms whose descriptor has no native pixel
        // dimensions (tvOS, visionOS). The canvas fills in a real size
        // once the bezel image loads and stores it on the layer.
        return CGSize(
            width:  CGFloat(config.nativeWidth)  * canvasPointsPerPixel,
            height: CGFloat(config.nativeHeight) * canvasPointsPerPixel
        )
    case .text:
        return CanvasIntrinsicFallback.text
    case .shape:
        return CanvasIntrinsicFallback.shape
    case .image:
        return CanvasIntrinsicFallback.image
    }
}

/// `true` when a content kind's size is ALWAYS intrinsic regardless of
/// an authored size — used to hide resize handles and skip the
/// authored-size fields in the inspector. Device bezels are NOT
/// always-intrinsic (aspect-locked corner resize is allowed); only
/// `.intrinsic`-expansion text qualifies.
public func isSizeAlwaysIntrinsic(for content: CanvasLayerContent?) -> Bool {
    switch content {
    case .text(_, let style): return style.expansion == .intrinsic
    default:                  return false
    }
}

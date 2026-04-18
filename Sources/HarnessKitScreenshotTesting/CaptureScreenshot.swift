import Foundation
import HarnessKitScreenshots
#if canImport(XCTest)
import XCTest
#if os(macOS)
import AppKit
import CoreGraphics
import ImageIO
import UniformTypeIdentifiers
#endif

/// Captures a screenshot during a UI test and attaches it with metadata-encoded name.
///
/// On macOS the app window is captured with rounded corners (35pt radius).
/// On watchOS only light-mode screenshots are captured.
/// On all other platforms a full-screen capture is performed.
///
/// The OS version is always resolved from the running device as `major.0`
/// and cannot be overridden by the caller.
///
/// - Parameters:
///   - screenshot: Metadata describing this screenshot (appearance, OS, crop, etc.).
///   - app: The `XCUIApplication` under test.
///   - sleepSeconds: Seconds to wait after applying the appearance before capturing.
///   - customActions: Additional setup actions to run before capturing.
///   - add: Closure that attaches an `XCTAttachment` to the current test.
@MainActor
public func captureScreenshot(
    screenshot: Screenshot,
    app: XCUIApplication,
    sleepSeconds: UInt32 = 2,
    customActions: () -> Void = { },
    add: (XCTAttachment) -> Void
) {
    let major = ProcessInfo.processInfo.operatingSystemVersion.majorVersion
    let resolvedScreenshot = screenshot.withOSVersion("\(major).0")

    #if os(iOS)
    if let orientation = resolvedScreenshot.orientation{
        setOrientation(to: orientation)
    }
    #endif
    #if !os(visionOS) && !os(watchOS)
    if #available(macOS 12.0, iOS 15.0, *) {
        let mappedTheme: XCUIDevice.Appearance = resolvedScreenshot.appearance == .light ? .light : .dark
        XCUIDevice.shared.appearance = mappedTheme
    }
    sleep(sleepSeconds)
    #endif
    customActions()
    #if os(macOS)
    let window = app.windows.firstMatch
    if window.exists {
        let windowShot = window.screenshot()
        if let roundedData = _roundedPNG(from: windowShot, cornerRadius: 35) {
            let attachment = XCTAttachment(
                uniformTypeIdentifier: "public.png",
                name: resolvedScreenshot.screenshotName(),
                payload: roundedData
            )
            attachment.lifetime = .keepAlways
            add(attachment)
        } else {
            let attachment = XCTAttachment(screenshot: windowShot)
            attachment.name = resolvedScreenshot.screenshotName()
            attachment.lifetime = .keepAlways
            add(attachment)
        }
    } else {
        let scr = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: scr)
        attachment.name = resolvedScreenshot.screenshotName()
        attachment.lifetime = .keepAlways
        add(attachment)
    }
    #elseif os(watchOS)
    sleep(1)
    if resolvedScreenshot.appearance != .dark {
        let scr = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: scr)
        attachment.name = resolvedScreenshot.screenshotName()
        attachment.lifetime = .keepAlways
        add(attachment)
    }
    #else
    let scr = XCUIScreen.main.screenshot()
    let attachment = XCTAttachment(screenshot: scr)
    attachment.name = resolvedScreenshot.screenshotName()
    attachment.lifetime = .keepAlways
    add(attachment)
    #endif
}

#if os(macOS)
@MainActor
private func _roundedPNG(
    from screenshot: XCUIScreenshot,
    cornerRadius: CGFloat,
    insets: NSEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: 0)
) -> Data? {
    _roundedPNG(fromPNG: screenshot.pngRepresentation, cornerRadius: cornerRadius, insets: insets)
}

/// Streams `pngData` through CGImageSource → CGContext (rounded clip) →
/// CGImageDestination. Avoids an NSImage → tiffRepresentation →
/// NSBitmapImageRep round-trip whose intermediate uncompressed TIFF is
/// ~13 MB at 1242×2688 — the dominant per-capture allocation in a UI test run.
/// `internal` so tests in `HarnessKitTransformTests` can drive it without
/// constructing an `XCUIScreenshot`.
internal func _roundedPNG(
    fromPNG pngData: Data,
    cornerRadius: CGFloat,
    insets: NSEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: 0)
) -> Data? {
    guard
        let source = CGImageSourceCreateWithData(pngData as CFData, nil),
        let cg = CGImageSourceCreateImageAtIndex(source, 0, nil)
    else { return nil }

    let width = cg.width
    let height = cg.height
    let rect = CGRect(x: 0, y: 0, width: width, height: height)
    let insetRect = rect.insetBy(
        dx: insets.left + insets.right > 0 ? insets.left : 0,
        dy: insets.top + insets.bottom > 0 ? insets.top : 0
    )

    let colorSpace = CGColorSpaceCreateDeviceRGB()
    guard let ctx = CGContext(
        data: nil,
        width: width,
        height: height,
        bitsPerComponent: 8,
        bytesPerRow: 0,
        space: colorSpace,
        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
    ) else { return nil }

    ctx.interpolationQuality = .high
    let clipPath = CGPath(
        roundedRect: insetRect,
        cornerWidth: cornerRadius,
        cornerHeight: cornerRadius,
        transform: nil
    )
    ctx.addPath(clipPath)
    ctx.clip()
    ctx.draw(cg, in: rect)

    guard let rounded = ctx.makeImage() else { return nil }

    let outData = NSMutableData()
    guard let dest = CGImageDestinationCreateWithData(
        outData, UTType.png.identifier as CFString, 1, nil
    ) else { return nil }
    CGImageDestinationAddImage(dest, rounded, nil)
    guard CGImageDestinationFinalize(dest) else { return nil }
    return outData as Data
}
#endif

#endif

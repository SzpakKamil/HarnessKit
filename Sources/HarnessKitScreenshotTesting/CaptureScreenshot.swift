//
//  CaptureScreenshot.swift
//  HarnessKitScreenshotTesting
//

import Foundation
import HarnessKitScreenshots
#if canImport(XCTest)
import XCTest

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
private func _roundedPNG(
    from screenshot: XCUIScreenshot,
    cornerRadius: CGFloat,
    insets: NSEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: 0)
) -> Data? {
    let data = screenshot.pngRepresentation
    guard let nsImage = NSImage(data: data) else { return nil }

    let size = nsImage.size
    let pixelSize = NSSize(width: size.width, height: size.height)

    let rect = NSRect(origin: .zero, size: pixelSize)
    let insetRect = rect.insetBy(
        dx: insets.left + insets.right > 0 ? insets.left : 0,
        dy: insets.top + insets.bottom > 0 ? insets.top : 0
    )

    let img = NSImage(size: pixelSize, flipped: false) { _ in
        NSGraphicsContext.current?.imageInterpolation = .high

        let path = NSBezierPath(roundedRect: insetRect, xRadius: cornerRadius, yRadius: cornerRadius)
        path.addClip()

        nsImage.draw(in: rect, from: .zero, operation: .sourceOver, fraction: 1.0)
        return true
    }

    guard
        let tiff = img.tiffRepresentation,
        let bitmap = NSBitmapImageRep(data: tiff),
        let png = bitmap.representation(using: .png, properties: [:])
    else {
        return nil
    }
    return png
}
#endif

#endif

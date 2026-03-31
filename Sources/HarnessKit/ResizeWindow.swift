//
//  ResizeWindow.swift
//  HarnessKitScreenshots
//

import SwiftUI

#if os(macOS)
import AppKit

public enum WindowSizeMode {
    case screen
    case custom(width: CGFloat, height: CGFloat)
}

public extension View {
    func windowSize(_ mode: WindowSizeMode) -> some View {
        self.onAppear {
            guard
                let window = NSApplication.shared.windows.first,
                let screen = window.screen ?? NSScreen.main
            else { return }

            switch mode {
            case .screen:
                let frame = screen.visibleFrame
                window.setFrame(frame, display: true)

            case .custom(let width, let height):
                let origin = CGPoint(
                    x: screen.visibleFrame.midX - width / 2,
                    y: screen.visibleFrame.midY - height / 2
                )
                let frame = CGRect(origin: origin, size: CGSize(width: width, height: height))
                window.setFrame(frame, display: true)
            }

            window.center()
        }
    }
}
#endif

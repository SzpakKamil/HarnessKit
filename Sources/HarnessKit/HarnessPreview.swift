//
//  HarnessPreview.swift
//  HarnessKit
//
//  Created by Kamil Szpak on 29/03/2026.
//

import SwiftUI

@MainActor
public struct HarnessPreview<Variant, Content: View>: View {

    private let variants: [Variant]
    private let content: (Variant) -> Content
    @State private var currentIndex: Int = 0

    public init(
        _ variants: [Variant],
        @ViewBuilder content: @escaping (Variant) -> Content
    ) {
        self.variants = variants
        self.content = content
    }

    @_documentation(visibility: internal)
    public var body: some View {
        if let variant = variants.isEmpty ? nil : variants[currentIndex] {
            platformContent(variant: variant)
        }
    }

    @ViewBuilder
    private func platformContent(variant: Variant) -> some View {
        #if os(tvOS)
        content(variant)
            .contentShape(Rectangle())
            .onPlayPauseCommand { advance() }
            .navigationBarBackButtonHidden(true)
            .accessibilityIdentifier("HarnessPreview")
        #elseif os(macOS)
        macOSContent(variant: variant)
        #else
        content(variant)
            .contentShape(Rectangle())
            .onTapGesture { advance() }
            .navigationBarBackButtonHidden(true)
            .accessibilityIdentifier("HarnessPreview")
        #endif
    }

    #if os(macOS)
    @ViewBuilder
    private func macOSContent(variant: Variant) -> some View {
        if #available(macOS 14, *) {
            content(variant)
                .contentShape(Rectangle())
                .focusable()
                .focusEffectDisabled()
                .onKeyPress(.downArrow) {
                    advance()
                    return .handled
                }
                .onTapGesture { advance() }
                .modifier(_ScrollWheelModifier(onScroll: advance))
                .navigationBarBackButtonHidden(true)
                .accessibilityIdentifier("HarnessPreview")
        } else {
            content(variant)
                .contentShape(Rectangle())
                .onTapGesture { advance() }
                .modifier(_ScrollWheelModifier(onScroll: advance))
                .accessibilityIdentifier("HarnessPreview")
        }
    }
    #endif

    private func advance() {
        guard !variants.isEmpty else { return }
        currentIndex = (currentIndex + 1) % variants.count
    }
}

extension HarnessPreview where Variant == Bool {
    public init(@ViewBuilder content: @escaping (Bool) -> Content) {
        self.init([false, true], content: content)
    }
}

#if os(macOS)
private struct _ScrollWheelModifier: ViewModifier {
    let onScroll: () -> Void
    func body(content: Content) -> some View {
        content.background(_ScrollWheelRepresentable(onScroll: onScroll))
    }
}

private struct _ScrollWheelRepresentable: NSViewRepresentable {
    let onScroll: () -> Void
    func makeNSView(context: Context) -> _ScrollWheelNSView {
        let view = _ScrollWheelNSView()
        view.onScroll = onScroll
        return view
    }
    func updateNSView(_ nsView: _ScrollWheelNSView, context: Context) {
        nsView.onScroll = onScroll
    }
}

private class _ScrollWheelNSView: NSView {
    var onScroll: (() -> Void)?
    override func scrollWheel(with event: NSEvent) {
        if event.deltaY > 0 { onScroll?() }
    }
}
#endif

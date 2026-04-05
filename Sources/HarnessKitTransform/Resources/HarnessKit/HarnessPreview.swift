//
//  HarnessPreview.swift
//  HarnessKit
//
//  Created by Kamil Szpak on 29/03/2026.
//

import SwiftUI
import Foundation

@MainActor
public struct HarnessPreview<Variant, Content: View>: View {

    private let variants: [Variant]
    private let content: (Variant) -> Content
    @State private var currentIndex: Int = 0
    @State private var lastAdvanceTime: Date = .distantPast

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
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
            .onPlayPauseCommand { advance() }
            .navigationBarBackButtonHidden(true)
            .accessibilityIdentifier("HarnessPreview")
        #elseif os(macOS)
        macOSContent(variant: variant)
        #else
        content(variant)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
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
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(Rectangle())
                .focusable()
                .focusEffectDisabled()
                .onKeyPress(.downArrow) {
                    advance()
                    return .handled
                }
                .onTapGesture { advance() }
                .navigationBarBackButtonHidden(true)
                .accessibilityIdentifier("HarnessPreview")
        } else {
            content(variant)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(Rectangle())
                .onTapGesture { advance() }
                .accessibilityIdentifier("HarnessPreview")
        }
    }
    #endif

    private func advance() {
        guard !variants.isEmpty else { return }
        
        let now = Date()
        guard now.timeIntervalSince(lastAdvanceTime) >= 2.0 else { return }
        
        lastAdvanceTime = now
        currentIndex = (currentIndex + 1) % variants.count
    }
}

extension HarnessPreview where Variant == Bool {
    public init(@ViewBuilder content: @escaping (Bool) -> Content) {
        self.init([false, true], content: content)
    }
}

//
//  HarnessView.swift
//  HarnessKit
//
//  Created by Kamil Szpak on 29/03/2026.
//

import SwiftUI

@MainActor
public struct HarnessView<Project: PathProject>: View {
    public init() {}

    @_documentation(visibility: internal)
    public var body: some View {
        if #available(iOS 16, macOS 13, tvOS 16, *) {
            NavigationStack {
                projectList
            }
        } else {
            NavigationView {
                projectList
            }
        }
    }

    @ViewBuilder
    private var projectList: some View {
        List {
            ForEach(Project.folders.indices, id: \.self) { index in
                let folder = Project.folders[index]
                NavigationLink(folder.name) {
                    HarnessFolderView(folder: folder)
                }
            }
        }
        .navigationTitle(Project.name)
    }
}

@MainActor
private func makeView(_ option: some PathFolder) -> AnyView {
    AnyView(option.view)
}

@MainActor
struct HarnessFolderView: View {
    let folder: any PathFolder.Type

    var body: some View {
        folderList
    }

    @ViewBuilder
    private var folderList: some View {
        List {
            ForEach(folder.folders.indices, id: \.self) { index in
                let subfolder = folder.folders[index]
                NavigationLink(subfolder.name) {
                    HarnessFolderView(folder: subfolder)
                }
            }
            ForEach(folder.options.indices, id: \.self) { index in
                let option = folder.options[index]
                NavigationLink(option.description) {
                    makeView(option)
                }
            }
        }
        .navigationTitle(folder.name)
    }

    init(folder: any PathFolder.Type) {
        self.folder = folder
    }
}

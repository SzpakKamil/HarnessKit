//
//  HarnessView.swift
//  HarnessKit
//
//  Created by Kamil Szpak on 29/03/2026.
//

import SwiftUI

public struct HarnessView<Project: PathProject>: View {
    public init() {}

    public var body: some View {
        NavigationStack {
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
}

struct HarnessFolderView: View {
    let folder: any PathFolder.Type

    var body: some View {
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
                    option.view
                }
            }
        }
        .navigationTitle(folder.name)
    }

    init(folder: any PathFolder.Type) {
        self.folder = folder
    }
}

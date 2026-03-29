import Testing
import SwiftUI
@testable import HarnessKit

struct HarnessKitTests {

    @MainActor
    enum MockProject: PathProject {
        static let name = "Project"
        static let folders: [any PathFolder.Type] = [MockFolder.self]
    }

    @MainActor
    enum MockFolder: PathFolder {
        typealias ParentSection = MockProject
        static let name = "Folder1"
        static let folders: [any PathFolder.Type] = [MockNestedFolder.self]
    }

    @MainActor
    enum MockNestedFolder: PathFolder {
        typealias ParentSection = MockFolder
        static let name = "NestedFolder"
        static let folders: [any PathFolder.Type] = [MockEnum.self]
    }

    @MainActor
    enum MockEnum: Int, PathFolder, CaseIterable {
        case first
        case second

        typealias ParentSection = MockNestedFolder
        static let name = "EnumFolder"
        static let folders: [any PathFolder.Type] = []
    }

    @Test func testProjectRoot() async throws {
        await MainActor.run {
            #expect(MockProject.pathIds == [])
            #expect(MockProject.nameComponents == [])
            #expect(MockProject.namePath == "")
        }
    }

    @Test func testFirstLevelFolder() async throws {
        await MainActor.run {
            #expect(MockFolder.pathIds == [0])
            #expect(MockFolder.nameComponents == ["Folder1"])
            #expect(MockFolder.namePath == "Folder1")
        }
    }

    @Test func testNestedFolder() async throws {
        await MainActor.run {
            #expect(MockNestedFolder.pathIds == [0, 0])
            #expect(MockNestedFolder.nameComponents == ["Folder1", "NestedFolder"])
            #expect(MockNestedFolder.namePath == "Folder1/NestedFolder")
        }
    }

    @Test func testEnumFolderType() async throws {
        await MainActor.run {
            #expect(MockEnum.pathIds == [0, 0, 0])
            #expect(MockEnum.nameComponents == ["Folder1", "NestedFolder", "EnumFolder"])
            #expect(MockEnum.namePath == "Folder1/NestedFolder/EnumFolder")
        }
    }

    @Test func testEnumCases() async throws {
        await MainActor.run {
            let firstCase = MockEnum.first
            #expect(firstCase.pathIds == [0, 0, 0, 0])
            #expect(firstCase.nameComponents == ["Folder1", "NestedFolder", "EnumFolder", "first"])
            #expect(firstCase.namePath == "Folder1/NestedFolder/EnumFolder/first")

            let secondCase = MockEnum.second
            #expect(secondCase.pathIds == [0, 0, 0, 1])
            #expect(secondCase.nameComponents == ["Folder1", "NestedFolder", "EnumFolder", "second"])
            #expect(secondCase.namePath == "Folder1/NestedFolder/EnumFolder/second")
        }
    }

    @Test func testResolverMethods() async throws {
        await MainActor.run {
            #expect(MockEnum.ids(for: MockEnum.first) == [0, 0, 0, 0])
            #expect(MockEnum.names(for: MockEnum.first) == ["Folder1", "NestedFolder", "EnumFolder", "first"])
            #expect(MockEnum.namePath(for: MockEnum.first) == "Folder1/NestedFolder/EnumFolder/first")

            #expect(MockEnum.ids(forType: MockEnum.self) == [0, 0, 0])
            #expect(MockEnum.names(forType: MockEnum.self) == ["Folder1", "NestedFolder", "EnumFolder"])
            #expect(MockEnum.namePath(forType: MockEnum.self) == "Folder1/NestedFolder/EnumFolder")
        }
    }
}

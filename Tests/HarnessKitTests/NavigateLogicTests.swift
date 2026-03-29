import Testing
@testable import HarnessKit

/// Tests that validate the computed inputs used by each platform's navigate() branch.
///
/// iOS / macOS:  navigate taps/clicks buttons by name in nameComponents order.
/// tvOS:         navigate presses down `id` times per entry in pathIds, then
///               presses down `folders.count + rawValue` times for the final option.
///
/// A mock hierarchy with two root sections covers:
///   - a folder at index > 0 (requires correct down-press count on tvOS)
///   - a folder that has BOTH sub-folders AND options (validates the offset)
struct NavigateLogicTests {

    // MARK: - Mock hierarchy
    //
    //  MockRoot
    //  ├── SectionA  (index 0)
    //  │   └── MixedFolder  (index 0)  ← has 1 sub-folder AND 2 option cases
    //  │       └── SubOfMixed  (index 0)
    //  └── SectionB  (index 1)
    //      └── LeafFolder  (index 0)   ← only options, no sub-folders

    @MainActor enum MockRoot: PathProject {
        static let name = "Root"
        static let folders: [any PathFolder.Type] = [SectionA.self, SectionB.self]
    }

    @MainActor enum SectionA: PathFolder {
        typealias ParentSection = MockRoot
        static let name = "SectionA"
        static let folders: [any PathFolder.Type] = [MixedFolder.self]
    }

    @MainActor enum SectionB: PathFolder {
        typealias ParentSection = MockRoot
        static let name = "SectionB"
        static let folders: [any PathFolder.Type] = [LeafFolder.self]
    }

    /// Has one sub-folder (SubOfMixed) AND two option cases (alpha, beta).
    /// On tvOS the option row must be offset by 1 (SubOfMixed occupies row 0).
    @MainActor enum MixedFolder: Int, PathFolder, CaseIterable {
        case alpha
        case beta
        typealias ParentSection = SectionA
        static let name = "MixedFolder"
        static let folders: [any PathFolder.Type] = [SubOfMixed.self]
    }

    @MainActor enum SubOfMixed: PathFolder {
        typealias ParentSection = MixedFolder
        static let name = "SubOfMixed"
        static let folders: [any PathFolder.Type] = []
    }

    /// No sub-folders, only option cases (one, two).
    @MainActor enum LeafFolder: Int, PathFolder, CaseIterable {
        case one
        case two
        typealias ParentSection = SectionB
        static let name = "LeafFolder"
        static let folders: [any PathFolder.Type] = []
    }

    // MARK: - iOS / macOS: name sequences

    /// navigate() on iOS/macOS taps buttons in nameComponents order.
    /// For a non-RawRepresentable folder the type-level nameComponents are used.
    @Test func iOSmacOS_folderNameSequence() async throws {
        await MainActor.run {
            // Navigating to SectionA taps one button
            #expect(SectionA.nameComponents == ["SectionA"])

            // Navigating to MixedFolder taps two buttons in order
            #expect(MixedFolder.nameComponents == ["SectionA", "MixedFolder"])

            // Navigating to SubOfMixed taps three buttons
            #expect(SubOfMixed.nameComponents == ["SectionA", "MixedFolder", "SubOfMixed"])

            // SectionB is the second root folder — still just one tap
            #expect(SectionB.nameComponents == ["SectionB"])

            // LeafFolder under SectionB
            #expect(LeafFolder.nameComponents == ["SectionB", "LeafFolder"])
        }
    }

    /// For a RawRepresentable case, names(for:) appends the case name at the end.
    @Test func iOSmacOS_optionNameSequence() async throws {
        await MainActor.run {
            #expect(MixedFolder.names(for: MixedFolder.alpha) == ["SectionA", "MixedFolder", "alpha"])
            #expect(MixedFolder.names(for: MixedFolder.beta)  == ["SectionA", "MixedFolder", "beta"])

            #expect(LeafFolder.names(for: LeafFolder.one) == ["SectionB", "LeafFolder", "one"])
            #expect(LeafFolder.names(for: LeafFolder.two) == ["SectionB", "LeafFolder", "two"])
        }
    }

    // MARK: - tvOS: folder-level path ids

    /// navigate() on tvOS loops over pathIds pressing down `id` times then select.
    @Test func tvOS_folderLevelPathIds() async throws {
        await MainActor.run {
            // SectionA: index 0 in Root → [0]
            #expect(SectionA.pathIds == [0])
            // SectionB: index 1 in Root → [1]
            #expect(SectionB.pathIds == [1])
            // MixedFolder: index 0 in SectionA → [0, 0]
            #expect(MixedFolder.pathIds == [0, 0])
            // LeafFolder: index 0 in SectionB → [1, 0]
            #expect(LeafFolder.pathIds == [1, 0])
        }
    }

    // MARK: - tvOS: option row with folder offset

    /// The final row index for an option is `folders.count + rawValue` because
    /// sub-folders occupy the top rows of the list before options.
    @Test func tvOS_optionRowWithFolderOffset() async throws {
        await MainActor.run {
            // MixedFolder has 1 sub-folder (SubOfMixed) before its options.
            // alpha (rawValue 0) → row 1 + 0 = 1
            // beta  (rawValue 1) → row 1 + 1 = 2
            #expect(MixedFolder.folders.count + MixedFolder.alpha.rawValue == 1)
            #expect(MixedFolder.folders.count + MixedFolder.beta.rawValue  == 2)

            // LeafFolder has no sub-folders so there is no offset.
            // one (rawValue 0) → row 0 + 0 = 0
            // two (rawValue 1) → row 0 + 1 = 1
            #expect(LeafFolder.folders.count + LeafFolder.one.rawValue == 0)
            #expect(LeafFolder.folders.count + LeafFolder.two.rawValue == 1)
        }
    }

    // MARK: - tvOS: full navigation plan per case

    /// Combines pathIds + optionRow to describe the complete tvOS remote sequence.
    ///
    /// Each entry in pathIds produces: (press .down `id` times) + (press .select).
    /// The final entry produces: (press .down `optionRow` times) + (press .select).
    @Test func tvOS_fullNavigationPlan() async throws {
        await MainActor.run {
            // MixedFolder.alpha
            // pathIds = [0, 0] → select (0 downs), select (0 downs)
            // optionRow = 1    → 1 down, select
            let alphaFolderIds = MixedFolder.pathIds          // [0, 0]
            let alphaOptionRow = MixedFolder.folders.count + MixedFolder.alpha.rawValue  // 1
            #expect(alphaFolderIds == [0, 0])
            #expect(alphaOptionRow == 1)

            // LeafFolder.two (under SectionB which is index 1)
            // pathIds = [1, 0] → 1 down + select, 0 downs + select
            // optionRow = 1    → 1 down, select
            let twoFolderIds = LeafFolder.pathIds              // [1, 0]
            let twoOptionRow = LeafFolder.folders.count + LeafFolder.two.rawValue        // 1
            #expect(twoFolderIds == [1, 0])
            #expect(twoOptionRow == 1)
        }
    }
}

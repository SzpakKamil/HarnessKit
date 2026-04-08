# ``HarnessKit/PathComponent``

@Metadata {
    @SupportedLanguage(swift)
    @Available(iOS, introduced: "14.0")
    @Available(iPadOS, introduced: "14.0")
    @Available(macOS, introduced: "11.0")
    @Available(tvOS, introduced: "14.0")
    @Available(watchOS, introduced: "10.0")
    @Available(visionOS, introduced: "1.0")
}

The shared protocol that both `PathProject` and `PathFolder` conform to.

## Overview

`PathComponent` is the building block that lets package authors ship pre-built harness subtrees. Any type conforming to `PathComponent` exposes a `folders` array, an `options` array (defaulting to `[]`), and the two path properties (`pathIds`, `nameComponents`) that `HarnessKit` uses internally to navigate and resolve nodes. Because `options` has a default empty implementation, retroactive conformances and project roots never need to provide it unless they want to expose navigable cases.

`PathProject` and `PathFolder` both refine `PathComponent`. Because `PathFolder.ParentSection` is typed as `any PathComponent`, a parent can be either the root project or another folder — which is how nesting works. It also means a library author can vend a standalone `PathFolder` subtree that consumers drop into any `PathProject.folders` without depending on a specific project type.

```swift
// A library ships this pre-built subtree:
public enum DesignTokensFolder: Int, PathFolder {
    public typealias ParentSection = any PathComponent  // not tied to a specific project
    public static let name = "Design Tokens"

    case colors
    case typography

    public var description: String { ... }
    public var view: some View { ... }
}

// Consumers add it to their own project with no changes:
enum MyProject: PathProject {
    static let name = "My App"
    static let folders: [any PathFolder.Type] = [
        DesignTokensFolder.self,
        MyOtherFolder.self
    ]
}
```

## Topics

### Requirements

- ``folders``
- ``options``
- ``pathIds``
- ``nameComponents``

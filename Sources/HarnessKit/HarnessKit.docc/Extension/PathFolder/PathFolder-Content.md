# ``HarnessKit/PathFolder/Content``

The SwiftUI `View` type returned by the ``HarnessKit/PathFolder/view`` property.

@Metadata {
    @SupportedLanguage(swift)
    @Available(iOS, introduced: "14.0")
    @Available(iPadOS, introduced: "14.0")
    @Available(macOS, introduced: "11.0")
    @Available(tvOS, introduced: "14.0")
    @Available(watchOS, introduced: "10.0")
    @Available(visionOS, introduced: "1.0")
    @Available(swift, introduced: "5.9")
    @Available(Xcode, introduced: "15.0")
    @DocumentationExtension(mergeBehavior: override)
}

@Options {
    @AutomaticSeeAlso(disabled)
    @AutomaticArticleSubheading(disabled)
}

The compiler infers this type from the concrete return type of ``HarnessKit/PathFolder/view`` at each conformance site. No explicit `typealias` is needed when using `some View` as the return type.

## Overview

In HarnessKit, `Content` represents the specific SwiftUI view that will be displayed when a user navigates to a particular case in a ``HarnessKit/PathFolder``. Because ``HarnessKit/PathFolder/view`` is typically marked with `@ViewBuilder`, this type often resolves to an internal SwiftUI type like `_ConditionalContent` or `EmptyView`.

### Automatic Inference

You rarely need to define this type manually. When you implement the ``HarnessKit/PathFolder/view`` property using `some View`, Swift's opaque return type mechanism automatically satisfies the `Content` requirement.

```swift
// The compiler automatically infers Content as 'some View'
var view: some View {
    Text("Hello, HarnessKit!")
}
```

## Example

The following example demonstrates a full HarnessKit hierarchy where `Content` is inferred for different cases within a folder.

```swift
import SwiftUI
import HarnessKit

// 1. Define the Root Project
enum MyDemoProject: PathProject {
    static let name = "Component Showcase"
    static let folders: [any PathFolder.Type] = [ButtonsFolder.self]
}

// 2. Define a Folder (Section)
enum ButtonsFolder: Int, PathFolder {
    typealias ParentSection = MyDemoProject
    static let name = "Buttons"

    case primary
    case secondary
    case destructive

    var description: String {
        switch self {
        case .primary: return "Primary Button"
        case .secondary: return "Secondary Button"
        case .destructive: return "Destructive Action"
        }
    }

    // 3. Define the View (Leaf Nodes)
    // The 'Content' associated type is inferred from this @ViewBuilder
    @ViewBuilder
    var view: some View {
        switch self {
        case .primary:
            Button("Confirm") { }
                .buttonStyle(.borderedProminent)
        case .secondary:
            Button("Cancel") { }
                .buttonStyle(.bordered)
        case .destructive:
            Button("Delete", role: .destructive) { }
                .buttonStyle(.bordered)
        }
    }
}

// 4. Render the Harness
struct MyHarnessApp: App {
    var body: some Scene {
        WindowGroup {
            HarnessView<MyDemoProject>()
        }
    }
}
```

## See Also

- ``HarnessKit/PathFolder/view``
- ``HarnessKit/PathFolder``
- ``HarnessKit/PathProject``

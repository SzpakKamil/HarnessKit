import Foundation
import HarnessKitScreenshots

/// One screenshot job for the bulk transform API.
///
/// - Important: Marked `@unchecked Sendable` because `PlatformImage`
///   (NSImage / UIImage) is not formally `Sendable` in Swift 6 strict
///   concurrency. The transform pipeline treats `PlatformImage` as
///   immutable bitmap data and reads it from each task's executor
///   concurrently — same pattern as the existing `nonisolated`
///   `transformScreenshot` function which already accepts `PlatformImage`
///   across thread boundaries.
///
///   Caller contract: the caller MUST NOT mutate `image` (or any of its
///   underlying representations) after passing it into the bulk API.
///
///   Removal plan: drop `@unchecked` to plain `Sendable` when Apple marks
///   `NSImage` / `UIImage` `Sendable` in a future SDK or Swift's
///   region-based isolation reliably accepts immutable-after-init class
///   types.
public struct TransformJob: @unchecked Sendable {
    public let image: PlatformImage
    public let screenshot: Screenshot

    public init(image: PlatformImage, screenshot: Screenshot) {
        self.image = image
        self.screenshot = screenshot
    }
}

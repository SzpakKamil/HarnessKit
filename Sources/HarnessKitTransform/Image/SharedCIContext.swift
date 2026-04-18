import CoreImage

/// Single shared Core Image context for the whole transform module.
///
/// Every shadow / canvas / effects pipeline stage should render
/// `CIImage`s through this context; using multiple `CIContext`
/// instances wastes GPU state and pays the ≈ 50–200 ms cold-start
/// penalty twice (once per context). Kept at Core Image's defaults
/// to preserve pixel-exact golden snapshots — tuning options
/// (e.g. `.priorityRequestLow`) is a separate concern.
enum SharedCIContext {
    static let context: CIContext = CIContext()
}

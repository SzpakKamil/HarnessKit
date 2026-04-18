// Pre-compiled `NSRegularExpression` instances for the handful of
// patterns used to parse device IDs. Each `bezelImage(color:)` call used
// to recompile these from string literals on every invocation (≈ 20 µs
// each). Batches of hundreds of screenshots now reuse a single compiled
// automaton.

import Foundation

enum BezelIDRegex {
    /// Processor suffix on iPad IDs, e.g. `iPadAir11M4` → `M4`,
    /// `iPadMiniA17Pro` → `A17Pro`. Returns `nil` for pre-processor IDs
    /// like `iPad9thGen`.
    static let processorSuffix = compile(#"(M\d+|A\d+[A-Za-z]*)$"#)

    /// `M`-series Mac ID: trailing digits + `M` + digits,
    /// e.g. `MacbookPro14M4`.
    static let macMProcessorWithSize = compile(#"\d+M\d+$"#)

    /// `A`-series Mac ID where the catalogue still expects the size prefix
    /// to be present, e.g. `MacbookNeo13A18Pro`.
    static let macAProcessorWithSize = compile(#"\d+A\d+[A-Za-z]*$"#)

    /// `A`-series Mac ID model portion alone, e.g. `A18Pro` out of
    /// `MacbookNeo13A18Pro` — used when extracting the model before
    /// extracting the size.
    static let macAProcessor = compile(#"A\d+[A-Za-z]*$"#)

    /// Trailing digits, e.g. `14` out of `MacbookPro14`.
    static let trailingDigits = compile(#"\d+$"#)

    private static func compile(_ pattern: String) -> NSRegularExpression {
        // Patterns are static literals validated at compile time; a
        // runtime failure here means the source was edited to an invalid
        // regex and should trap loudly.
        try! NSRegularExpression(pattern: pattern)
    }
}

extension String {
    /// Returns the range of the first regex match, or `nil` if none.
    /// Mirrors `range(of:options:.regularExpression)` semantics without
    /// recompiling the pattern on each call.
    func firstMatch(of regex: NSRegularExpression) -> Range<String.Index>? {
        let ns = self as NSString
        let r = regex.firstMatch(in: self, range: NSRange(location: 0, length: ns.length))
        guard let r, r.range.location != NSNotFound else { return nil }
        return Range(r.range, in: self)
    }
}

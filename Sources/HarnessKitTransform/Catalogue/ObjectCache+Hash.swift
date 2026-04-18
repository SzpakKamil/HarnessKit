import Foundation
import CryptoKit

/// Precomputed lowercase-hex table: `hexTable[i] == String(format: "%02x", i)`.
/// Static constant so we pay the 256 × 2-char init cost exactly once per
/// process rather than per-byte-per-hash.
private let hexTable: [String] = (0...255).map { byte in
    String(format: "%02x", byte)
}

extension ObjectCache {

    static func hash(data: Data) -> String {
        hexEncode(SHA256.hash(data: data))
    }

    /// Streaming SHA256 over an on-disk file. Reads 64 KB at a time so
    /// even a 500 MB bezel stays at ~64 KB steady-state RAM during the
    /// hash step — previously the whole file was slurped into Data and
    /// hashed in-memory.
    ///
    /// Leak safety: `FileHandle` closed via `defer` regardless of
    /// whether reads throw or end cleanly.
    static func hashFile(at url: URL) throws -> String {
        let handle = try FileHandle(forReadingFrom: url)
        defer { try? handle.close() }

        var hasher = SHA256()
        let chunkSize = 64 * 1024
        while true {
            let chunk: Data
            if #available(macOS 10.15.4, iOS 13.4, tvOS 13.4, watchOS 6.2, *) {
                chunk = try handle.read(upToCount: chunkSize) ?? Data()
            } else {
                chunk = handle.readData(ofLength: chunkSize)
            }
            if chunk.isEmpty { break }
            hasher.update(data: chunk)
        }
        return hexEncode(hasher.finalize())
    }

    /// Encodes a `SHA256.Digest` (or any `Sequence<UInt8>`) as lowercase hex
    /// using a static 256-entry lookup table. Replaces the previous
    /// `.map { String(format: "%02x", $0) }.joined()` chain which allocated
    /// one small String per byte (32 per hash) plus the joined Array — hot
    /// path because it runs once per download.
    static func hexEncode<S: Sequence>(_ bytes: S) -> String where S.Element == UInt8 {
        // Two characters per byte; reserve to avoid COW growth.
        var out = ""
        if let count = (bytes as? any Collection)?.count {
            out.reserveCapacity(count * 2)
        }
        for byte in bytes {
            out.append(hexTable[Int(byte)])
        }
        return out
    }
}

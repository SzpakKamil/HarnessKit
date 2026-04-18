import Foundation
import os.lock

/// Thread-safe storage for the catalogue base URL. Lives outside the actor so
/// `nonisolated` getters/setters can read it from any isolation context without
/// the `nonisolated(unsafe)` escape hatch. Backed by `os_unfair_lock_s` to keep
/// the package on its macOS 11 / iOS 14 deployment floor (`OSAllocatedUnfairLock`
/// is macOS 13+).
final class BaseURLConfig: @unchecked Sendable {
    static let shared = BaseURLConfig()

    private var _lock = os_unfair_lock_s()
    private var _url: URL = URL(string: "https://harnesskitassets.kamilszpak.com")!

    var url: URL {
        os_unfair_lock_lock(&_lock); defer { os_unfair_lock_unlock(&_lock) }
        return _url
    }

    func setURL(_ url: URL) {
        os_unfair_lock_lock(&_lock); defer { os_unfair_lock_unlock(&_lock) }
        _url = url
    }
}

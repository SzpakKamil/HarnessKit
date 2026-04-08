//
//  GenerationCache.swift
//  HarnessKitTransform
//
//  A thread-safe cache that rebuilds its contents when `CatalogueStore.generation` changes.
//  Used for both device descriptor catalogues and bezel filename indexes.
//

import Foundation

/// A thread-safe cache that rebuilds when `CatalogueStore.generation` changes.
///
/// Callers access the cached value via `current()`. The first call (or any call after
/// `CatalogueStore` installs a new manifest) triggers a rebuild via the `builder` closure.
///
/// - Important: Thread safety is guaranteed by `NSLock` protecting all mutable state.
final class GenerationCache<T>: @unchecked Sendable {
    private let lock = NSLock()
    private var cachedGeneration: Int = -1
    private var cached: [T] = []
    private let builder: () -> [T]

    init(builder: @escaping () -> [T]) {
        self.builder = builder
    }

    func current() -> [T] {
        let generation = CatalogueStore.shared.generation
        lock.lock(); defer { lock.unlock() }
        if generation == cachedGeneration { return cached }
        cached = builder()
        cachedGeneration = generation
        return cached
    }
}

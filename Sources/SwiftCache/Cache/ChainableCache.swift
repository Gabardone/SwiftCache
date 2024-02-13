//
//  ChainableCache.swift
//
//
//  Created by Óscar Morales Vivó on 4/22/23.
//

import Foundation
import os

/**
 A configurable chainable cache that temporarily stores data from its `next` cache and returns it if requested again.

 More sophisticated caching will have multiple levels. For example if we're caching images for display that are stored
 in a network backend we'd want to first look in memory, then in temporary storage inside the app's sandbox, and finally
 on the network itself. Each operation is more costly than the prior one but also uses less valuable resources (RAM,
 device storage and network storage in the example given).

 Front and intermediate steps in a cache chain can be implemented using this type. Quick common specializations using
 the provided storage implementations can be built with the respective factory methods.
 */
public actor ChainableCache<Cached, CacheID: Hashable, Next: Cache, Stored, StorageID: Hashable>
    where Next.CacheID == CacheID {
    /**
     Initializes with a next cache, a storage and a full set of injectable behaviors.

     Factory methods are provided for common use cases. This can still be used for custom building a full temporary
     cache.
     - Parameter next: The next cache in the chain. Immutable once set. If `nil`, this will be the last cache in the
     cache chain.
     - Parameter storage: The storage used to store and fetch cached values.
     - Parameter nextConverter: An injectable block that converts values from the next cache into values that can be
     stored and returned by self.
     - Parameter idConverter: A block that converts cache IDs to storage IDs for the cache's storage.
     - Parameter fromStorageConverter: A block that converts storage values into cache values.
     - Parameter toStorageConverter: A block that converts cache values into storage values.
     */
    public init(
        next: Next?,
        storage: some ValueStorage<Stored, StorageID>,
        nextConverter: @escaping NextConverter,
        idConverter: @escaping IDConverter,
        fromStorageConverter: @escaping FromStorageConverter,
        toStorageConverter: @escaping ToStorageConverter
    ) {
        self.next = next
        self.nextConverter = nextConverter
        self.storage = storage
        self.idConverter = idConverter
        self.fromStorageConverter = fromStorageConverter
        self.toStorageConverter = toStorageConverter
    }

    // MARK: - Types

    /**
     Type of block used to convert from `next` cached values to our cached values.
     */
    public typealias NextConverter = (Next.Cached) async throws -> Cached

    /**
     Block used to convert cache IDs to storage IDs. Unlike the other injectable behaviors, this is expected to always
     work and do so synchronously.
     */
    public typealias IDConverter = (CacheID) -> StorageID

    /**
     Type of block used to convert from stored values to cache values.
     */
    public typealias FromStorageConverter = (Stored) async throws -> (Cached)

    /**
     Type of block used to convert from cached values to stored values.
     */
    public typealias ToStorageConverter = (Cached) async throws -> (Stored)

    // MARK: - Stored Properties

    /**
     The next cache in the chain must use the same kind of cache ID, although it may interpret it differently.
     */
    public let next: Next?

    private let nextConverter: NextConverter

    private let storage: any ValueStorage<Stored, StorageID>

    private let idConverter: IDConverter

    private let fromStorageConverter: FromStorageConverter

    private let toStorageConverter: ToStorageConverter

    private var taskManager = [CacheID: Task<Cached?, Error>]()
}

// MARK: - Cache Adoption

extension ChainableCache: Cache {
    public typealias Cached = Cached

    public typealias CacheID = CacheID

    public func cachedValueWith(identifier: CacheID) async throws -> Cached? {
        if let ongoingTask = taskManager[identifier] {
            // Avoid reentrancy, just wait for the ongoing task that is already doing the stuff.
            return try await ongoingTask.value
        } else {
            let newTask = Task<Cached?, Error> {
                defer {
                    // No matter what happens at the end we want to clear out the task in the manager.
                    taskManager.removeValue(forKey: identifier)
                }

                if let stored = try await storage.valueFor(identifier: idConverter(identifier)) {
                    return try await fromStorageConverter(stored)
                } else if let next, let nextValue = try await next.cachedValueWith(identifier: identifier) {
                    let value = try await processFromNext(nextValue: nextValue)
                    do {
                        try await store(value: value, identifier: identifier)
                    } catch {
                        // This is bad but we can still return the value.
                        Logger.cache.error("TemporaryStorageCache unable to store value with identifier: \(String(describing: identifier)), error: \(error.localizedDescription)")
                    }
                    return value
                } else {
                    return nil
                }
            }

            taskManager[identifier] = newTask
            return try await newTask.value
        }
    }

    public func invalidateCachedValueFor(identifier: CacheID) async throws {
        try await storage.removeValueFor(identifier: idConverter(identifier))

        try await next?.invalidateCachedValueFor(identifier: identifier)
    }
}

public extension ChainableCache {
    typealias Next = Next

    /**
     Translates a cached value returned from `next` into one of the type that `self` manages. May throw if conversion is
     not possible.
     - Parameter nextValue: The value returned from `next`.
     - Returns: An equivalent value of the type managed by the caller.
     */
    func processFromNext(nextValue: Next.Cached) async throws -> Cached {
        try await nextConverter(nextValue)
    }

    /**
     Stores a value returned from `next` into this cache's storage.

     After this, a call to ``cachedValueWith(identifier:)`` should return `value` unless the cache was cleared
     inbetween.

     If storage is not possible for whatever reason the method will `throw` and no storage will happen.
     - Parameter value: The value to store in the cache.
     - Parameter identifier: The identifier to use to store the value.
     */
    func store(value: Cached, identifier: CacheID) async throws {
        try await storage.store(
            value: toStorageConverter(value),
            identifier: idConverter(identifier)
        )
    }
}

// MARK: - Helper Initializers

public extension ChainableCache where Next.Cached == Cached {
    init(
        next: Next?,
        storage: some ValueStorage<Stored, StorageID>,
        idConverter: @escaping IDConverter,
        fromStorageConverter: @escaping FromStorageConverter,
        toStorageConverter: @escaping ToStorageConverter
    ) {
        self.init(
            next: next,
            storage: storage,
            nextConverter: { $0 },
            idConverter: idConverter,
            fromStorageConverter: fromStorageConverter,
            toStorageConverter: toStorageConverter
        )
    }
}

public extension ChainableCache where CacheID == StorageID {
    init(
        next: Next?,
        storage: some ValueStorage<Stored, StorageID>,
        nextConverter: @escaping NextConverter,
        fromStorageConverter: @escaping FromStorageConverter,
        toStorageConverter: @escaping ToStorageConverter
    ) {
        self.init(
            next: next,
            storage: storage,
            nextConverter: nextConverter,
            idConverter: { $0 },
            fromStorageConverter: fromStorageConverter,
            toStorageConverter: toStorageConverter
        )
    }
}

public extension ChainableCache where Cached == Stored {
    init(
        next: Next?,
        storage: some ValueStorage<Stored, StorageID>,
        nextConverter: @escaping NextConverter,
        idConverter: @escaping IDConverter
    ) {
        self.init(
            next: next,
            storage: storage,
            nextConverter: nextConverter,
            idConverter: idConverter,
            fromStorageConverter: { $0 },
            toStorageConverter: { $0 }
        )
    }
}

public extension ChainableCache where CacheID == StorageID, Cached == Stored {
    init(next: Next?, storage: some ValueStorage<Stored, StorageID>, nextConverter: @escaping NextConverter) {
        self.init(
            next: next,
            storage: storage,
            nextConverter: nextConverter,
            idConverter: { $0 },
            fromStorageConverter: { $0 },
            toStorageConverter: { $0 }
        )
    }
}

public extension ChainableCache where Next.Cached == Cached, Cached == Stored {
    init(next: Next?, storage: some ValueStorage<Stored, StorageID>, idConverter: @escaping IDConverter) {
        self.init(
            next: next,
            storage: storage,
            nextConverter: { $0 },
            idConverter: idConverter,
            fromStorageConverter: { $0 },
            toStorageConverter: { $0 }
        )
    }
}

public extension ChainableCache where Next.Cached == Cached, CacheID == StorageID {
    init(
        next: Next?,
        storage: some ValueStorage<Stored, StorageID>,
        nextConverter: @escaping NextConverter,
        fromStorageConverter: @escaping FromStorageConverter,
        toStorageConverter: @escaping ToStorageConverter
    ) {
        self.init(
            next: next,
            storage: storage,
            nextConverter: nextConverter,
            idConverter: { $0 },
            fromStorageConverter: fromStorageConverter,
            toStorageConverter: toStorageConverter
        )
    }
}

public extension ChainableCache where Next.Cached == Cached, CacheID == StorageID, Cached == Stored {
    init(next: Next?, storage: some ValueStorage<Stored, StorageID>) {
        self.init(
            next: next,
            storage: storage,
            nextConverter: { $0 },
            idConverter: { $0 },
            fromStorageConverter: { $0 },
            toStorageConverter: { $0 }
        )
    }
}

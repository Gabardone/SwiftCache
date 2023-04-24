//
//  TemporaryStorageCache.swift
//
//
//  Created by Óscar Morales Vivó on 4/22/23.
//

import Foundation

/**
 A configurable chainable cache that temporarily stores data from its `next` cache and returns it if requested again.

 Most front and intermediate steps in a cache chain can be implemented using this type. Quick common specializations
 using the provided storage implementations can be built with the respective factory methods.
 */
public actor TemporaryStorageCache<Cached, CacheID: Hashable, Next: Cache, Stored, StorageID: Hashable>
    where Next.CacheID == CacheID {
    /**
     Initializes with a next cache, a storage and a full set of injectable behaviors.

     Factory methods are provided for common use cases. This can still be used for custom building a full temporary
     cache.
     - Parameter next: The next cache in the chain. Immutable once set. If `nil`, this will be the last cache in the
     cache chain.
     - Parameter nextConverter: An injectable block that converts values from the next cache into values that can be
     stored and returned by self.
     - Parameter storage: The storage used to store and fetch cached values.
     - Parameter idConverter: A block that converts cache IDs to storage IDs for the cache's storage.
     - Parameter fromStorageConverter: A block that converts storage values into cache values.
     - Parameter toStorageConverter: A block that converts cache values into storage values.
     */
    public init(
        next: Next?,
        nextConverter: @escaping NextConverter,
        storage: some Storage<Stored, StorageID>,
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

    public let next: Next?

    private let nextConverter: NextConverter

    private let storage: any Storage<Stored, StorageID>

    private let idConverter: IDConverter

    private let fromStorageConverter: FromStorageConverter

    private let toStorageConverter: ToStorageConverter
}

// MARK: - Cache Adoption

extension TemporaryStorageCache: Cache {
    public typealias Cached = Cached

    public typealias CacheID = CacheID

    public func cachedValueWith(identifier: CacheID) async throws -> Cached? {
        if let stored = try await storage.storedValueFor(identifier: idConverter(identifier)) {
            return try await fromStorageConverter(stored)
        } else {
            return nil
        }
    }
}

extension TemporaryStorageCache: ChainableCache {
    public typealias Next = Next

    public func processFromNext(nextValue: Next.Cached) async throws -> Cached {
        try await nextConverter(nextValue)
    }

    public func store(value: Cached, identifier: CacheID) async throws {
        try await storage.store(
            value: toStorageConverter(value),
            identifier: idConverter(identifier)
        )
    }
}

// MARK: - Helper Initializers

public extension TemporaryStorageCache where Next.Cached == Cached {
    init(
        next: Next?,
        storage: some Storage<Stored, StorageID>,
        idConverter: @escaping IDConverter,
        fromStorageConverter: @escaping FromStorageConverter,
        toStorageConverter: @escaping ToStorageConverter
    ) {
        self.init(
            next: next,
            nextConverter: { $0 },
            storage: storage,
            idConverter: idConverter,
            fromStorageConverter: fromStorageConverter,
            toStorageConverter: toStorageConverter
        )
    }
}

public extension TemporaryStorageCache where CacheID == StorageID {
    init(
        next: Next?,
        nextConverter: @escaping NextConverter,
        storage: some Storage<Stored, StorageID>,
        fromStorageConverter: @escaping FromStorageConverter,
        toStorageConverter: @escaping ToStorageConverter
    ) {
        self.init(
            next: next,
            nextConverter: nextConverter,
            storage: storage,
            idConverter: { $0 },
            fromStorageConverter: fromStorageConverter,
            toStorageConverter: toStorageConverter
        )
    }
}

public extension TemporaryStorageCache where Cached == Stored {
    init(
        next: Next?,
        nextConverter: @escaping NextConverter,
        storage: some Storage<Stored, StorageID>,
        idConverter: @escaping IDConverter
    ) {
        self.init(
            next: next,
            nextConverter: nextConverter,
            storage: storage,
            idConverter: idConverter,
            fromStorageConverter: { $0 },
            toStorageConverter: { $0 }
        )
    }
}

public extension TemporaryStorageCache where CacheID == StorageID, Cached == Stored {
    init(next: Next?, nextConverter: @escaping NextConverter, storage: some Storage<Stored, StorageID>) {
        self.init(
            next: next,
            nextConverter: nextConverter,
            storage: storage,
            idConverter: { $0 },
            fromStorageConverter: { $0 },
            toStorageConverter: { $0 }
        )
    }
}

public extension TemporaryStorageCache where Next.Cached == Cached, Cached == Stored {
    init(
        next: Next?,
        nextConverter _: @escaping NextConverter,
        storage: some Storage<Stored, StorageID>,
        idConverter: @escaping IDConverter
    ) {
        self.init(
            next: next,
            nextConverter: { $0 },
            storage: storage,
            idConverter: idConverter,
            fromStorageConverter: { $0 },
            toStorageConverter: { $0 }
        )
    }
}

public extension TemporaryStorageCache where Next.Cached == Cached, CacheID == StorageID {
    init(
        next: Next?,
        nextConverter _: @escaping NextConverter,
        storage: some Storage<Stored, StorageID>,
        fromStorageConverter: @escaping FromStorageConverter,
        toStorageConverter: @escaping ToStorageConverter
    ) {
        self.init(
            next: next,
            nextConverter: { $0 },
            storage: storage,
            idConverter: { $0 },
            fromStorageConverter: fromStorageConverter,
            toStorageConverter: toStorageConverter
        )
    }
}

public extension TemporaryStorageCache where Next.Cached == Cached, CacheID == StorageID, Cached == Stored {
    init(next: Next?, storage: some Storage<Stored, StorageID>) {
        self.init(
            next: next,
            nextConverter: { $0 },
            storage: storage,
            idConverter: { $0 },
            fromStorageConverter: { $0 },
            toStorageConverter: { $0 }
        )
    }
}

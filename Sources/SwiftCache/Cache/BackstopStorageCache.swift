//
//  BackstopStorageCache.swift
//
//
//  Created by Óscar Morales Vivó on 4/23/23.
//

import Foundation

/**
 A configurable chainable cache that retrieves data from its storage.

 This is meant for the end of a cache chain as a final backstop for finding the requested data. Common examples would
 be network-backed values or from other storage that we are not meant to modify.
 */
public actor BackstopStorageCache<Cached, CacheID: Hashable, Stored, StorageID: Hashable> {
    /**
     Initializes with a storage and a full set of injectable behaviors.

     Factory methods are provided for common use cases. This can still be used for custom building a full backstop
     storage cache.
     - Parameter storage: The storage where we will attempt to fetch values from.
     - Parameter idConverter: A block that converts cache IDs to storage IDs for the cache's storage.
     - Parameter fromStorageConverter: A block that converts storage values into cache values.
     */
    public init(
        storage: some ReadOnlyStorage<Stored, StorageID>,
        idConverter: @escaping IDConverter,
        fromStorageConverter: @escaping FromStorageConverter
    ) {
        self.storage = storage
        self.idConverter = idConverter
        self.fromStorageConverter = fromStorageConverter
    }

    // MARK: - Types

    /**
     Block used to convert cache IDs to storage IDs. Unlike the other injectable behaviors, this is expected to always
     work and do so synchronously.
     */
    public typealias IDConverter = (CacheID) -> StorageID

    /**
     Type of block used to convert from stored values to cache values.
     */
    public typealias FromStorageConverter = (Stored) async throws -> (Cached)

    // MARK: - Stored Properties

    private let storage: any ReadOnlyStorage<Stored, StorageID>

    private let idConverter: IDConverter

    private let fromStorageConverter: FromStorageConverter
}

// MARK: - Cache Adoption

extension BackstopStorageCache: Cache {
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

// MARK: - Helper Initializers

public extension BackstopStorageCache where CacheID == StorageID {
    init(
        storage: some Storage<Stored, StorageID>,
        fromStorageConverter: @escaping FromStorageConverter
    ) {
        self.init(
            storage: storage,
            idConverter: { $0 },
            fromStorageConverter: fromStorageConverter
        )
    }
}

public extension BackstopStorageCache where Cached == Stored {
    init(storage: some Storage<Stored, StorageID>, idConverter: @escaping IDConverter) {
        self.init(
            storage: storage,
            idConverter: idConverter,
            fromStorageConverter: { $0 }
        )
    }
}

public extension BackstopStorageCache where CacheID == StorageID, Cached == Stored {
    init(storage: some Storage<Stored, StorageID>) {
        self.init(
            storage: storage,
            idConverter: { $0 },
            fromStorageConverter: { $0 }
        )
    }
}

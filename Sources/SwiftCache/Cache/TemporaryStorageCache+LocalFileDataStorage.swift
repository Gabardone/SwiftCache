//
//  TemporaryStorageCache+LocalFileDataStorage.swift
//
//
//  Created by Óscar Morales Vivó on 6/23/23.
//

import Foundation

public extension TemporaryStorageCache where StorageID == URL, Stored == Data {
    /**
     Initializer for a cache folder local file system temporary storage cache.

     This initializer is meant to work for passing in a `LocalFileDataStorage` as the cache storage, but can be used
     with other storage implementations that have a similar profile (i.e. testing mocks). It will take in a root
     directory URL and convert the cache ID into file names to read/write files from it.

     Beyond that it's the same as the regular `TemporaryStorageCache` initializer.
     - Parameter next: The next cache in the chain. Immutable once set. If `nil`, this will be the last cache in the
     cache chain.
     - Parameter storage: The storage used to store and fetch cached values.
     - Parameter rootDirectory: A directory which will circumscribe the storage, using the string version of the cache
     IDs as file names. Will be created if needed but must be writeable. Usually a subdirectory of
     `FileManager.temporaryDirectory`
     - Parameter nextConverter: An injectable block that converts values from the next cache into values that can be
     stored and returned by self.
     - Parameter fromStorageConverter: A block that converts storage values into cache values.
     - Parameter toStorageConverter: A block that converts cache values into storage values.
     */
    init(
        next: Next?,
        storage: some ValueStorage<Data, URL>,
        rootDirectory: URL,
        nextConverter: @escaping NextConverter,
        fromStorageConverter: @escaping FromStorageConverter,
        toStorageConverter: @escaping ToStorageConverter
    ) {
        self.init(
            next: next,
            storage: storage,
            nextConverter: nextConverter,
            idConverter: { cacheID in
                rootDirectory.appendingPathComponent("\(cacheID)", isDirectory: false)
            },
            fromStorageConverter: fromStorageConverter,
            toStorageConverter: toStorageConverter
        )
    }
}

// MARK: - Helper Initializers

public extension TemporaryStorageCache where Next.Value == Value, StorageID == URL, Stored == Data {
    init(
        next: Next?,
        storage: some ValueStorage<Stored, StorageID>,
        rootDirectory: URL,
        fromStorageConverter: @escaping FromStorageConverter,
        toStorageConverter: @escaping ToStorageConverter
    ) {
        self.init(
            next: next,
            storage: storage,
            rootDirectory: rootDirectory,
            nextConverter: { $0 },
            fromStorageConverter: fromStorageConverter,
            toStorageConverter: toStorageConverter
        )
    }
}

public extension TemporaryStorageCache where Value == Stored, StorageID == URL, Stored == Data {
    init(
        next: Next?,
        storage: some ValueStorage<Stored, StorageID>,
        rootDirectory: URL,
        nextConverter: @escaping NextConverter
    ) {
        self.init(
            next: next,
            storage: storage,
            rootDirectory: rootDirectory,
            nextConverter: nextConverter,
            fromStorageConverter: { $0 },
            toStorageConverter: { $0 }
        )
    }
}

public extension TemporaryStorageCache where Next.Value == Value, Value == Stored, StorageID == URL, Stored == Data {
    init(next: Next?, storage: some ValueStorage<Stored, StorageID>, rootDirectory: URL) {
        self.init(
            next: next,
            storage: storage,
            rootDirectory: rootDirectory,
            nextConverter: { $0 },
            fromStorageConverter: { $0 },
            toStorageConverter: { $0 }
        )
    }
}

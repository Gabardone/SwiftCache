//
//  GeneratorStorage.swift
//
//
//  Created by Óscar Morales Vivó on 4/24/23.
//

import Foundation

/**
 A type of read-only storage that generates values instead of fetching them.

 This should be used attached to a `BackstopStorageCache` so its results are stored elsewhere in the cache chain.
 Otherwise you'll be generating the values all the time which doesn't sound like caching to anyone.
 */
public struct GeneratorStorage<Stored, StorageID: Hashable> {
    /**
     Initialize with generator logic.

     The passed in block will be run any time the storage is asked for a value.
     - Parameter generator: The logic to run to generate values for the given identifiers.
     */
    public init(generator: @escaping Generator) {
        self.generator = generator
    }

    // MARK: - Types

    /**
     Block type that generates new values based on identifiers.
     */
    public typealias Generator = (StorageID) async throws -> Stored?

    // MARK: - Stored Properties

    private let generator: Generator
}

// MARK: - ReadOnlyStorage Adoption

extension GeneratorStorage: StorageSource {
    public typealias Stored = Stored

    public typealias StorageID = StorageID

    public func storedValueFor(identifier: StorageID) async throws -> Stored? {
        try await generator(identifier)
    }
}

//
//  ComposableStorage.swift
//  SwiftCache
//
//  Created by Óscar Morales Vivó on 4/11/23.
//

import Foundation

/**
 Simple storage implementation that can be built by hand.

 Set up its override blocks to specify the behavior you want.

 Doubles as a mock type for testing. For real implementations make sure to set up all behaviors.

 Declared as a reference type so the overrides can be "safely" swapped during a test.
 */
public class ComposableStorage<Stored, StorageID: Hashable> {
    /// Swift made us declare this.
    public init(
        storeOverride: ((Stored, StorageID) async throws -> Void)? = nil,
        storedValueForOverride: ((StorageID) async throws -> Stored)? = nil
    ) {
        self.storeOverride = storeOverride
        self.storedValueForOverride = storedValueForOverride
    }

    // MARK: - Types

    /// Error thrown when a method is called with no override set.
    struct UnimplementedError: Error {}

    // MARK: - Stored Properties

    public var storeOverride: ((Stored, StorageID) async throws -> Void)?

    public var storedValueForOverride: ((StorageID) async throws -> Stored?)?

    public var removeValueForOverride: ((StorageID) async throws -> Void)?
}

extension ComposableStorage: Storage {
    public typealias Stored = Stored

    public typealias StorageID = StorageID

    public func store(value: Stored, identifier: StorageID) async throws {
        guard let storeOverride else {
            throw UnimplementedError()
        }

        try await storeOverride(value, identifier)
    }

    public func storedValueFor(identifier: StorageID) async throws -> Stored? {
        guard let storedValueForOverride else {
            throw UnimplementedError()
        }

        return try await storedValueForOverride(identifier)
    }

    public func removeValueFor(identifier: StorageID) async throws {
        guard let removeValueForOverride else {
            throw UnimplementedError()
        }

        return try await removeValueForOverride(identifier)
    }
}

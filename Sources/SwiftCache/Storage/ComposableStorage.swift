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
        valueForOverride: ((StorageID) async throws -> Stored)? = nil
    ) {
        self.storeOverride = storeOverride
        self.valueForOverride = valueForOverride
    }

    // MARK: - Types

    /// Error thrown when a method is called with no override set.
    struct UnimplementedError: Error {}

    // MARK: - Stored Properties

    public var storeOverride: ((Stored, StorageID) async throws -> Void)?

    public var valueForOverride: ((StorageID) async throws -> Stored?)?

    public var removeValueForOverride: ((StorageID) async throws -> Void)?
}

extension ComposableStorage: ValueStorage {
    public typealias Stored = Stored

    public typealias StorageID = StorageID

    public func store(value: Stored, identifier: StorageID) async throws {
        guard let storeOverride else {
            throw UnimplementedError()
        }

        try await storeOverride(value, identifier)
    }

    public func valueFor(identifier: StorageID) async throws -> Stored? {
        guard let valueForOverride else {
            throw UnimplementedError()
        }

        return try await valueForOverride(identifier)
    }

    public func removeValueFor(identifier: StorageID) async throws {
        guard let removeValueForOverride else {
            throw UnimplementedError()
        }

        return try await removeValueForOverride(identifier)
    }
}

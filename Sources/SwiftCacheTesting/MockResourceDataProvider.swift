//
//  MockResourceDataProvider.swift
//  SwiftCache
//
//  Created by Óscar Morales Vivó on 4/11/23.
//

import Foundation
import SwiftCache

/**
 Simple mock resource data provider for testing purposes.

 Set up its override blocks to specify the behavior you want.

 Declared as a reference type so the overrides can be "safely" swapped during a test.
 */
public class MockStorage<Stored, StorageID: Hashable> {
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

extension MockStorage: Storage {
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

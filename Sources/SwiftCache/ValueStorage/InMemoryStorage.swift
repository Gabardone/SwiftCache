//
//  InMemoryStorage.swift
//
//
//  Created by Óscar Morales Vivó on 9/12/23.
//

import Foundation

/**
 Standard in-memory storage.

 If used with reference types, either directly or indirectly, it may cause reference cycles. Access to the storage from
 outside the cache may be warranted to clean up unneeded items or do other maintenance.

 The type is an `actor` as to ensure thread safety for access to its internal storage.
 */
public actor InMemoryStorage<Stored, StorageID: Hashable> {
    public init() {}

    // MARK: - Stored Properties

    private var storage = [StorageID: Stored]()
}

extension InMemoryStorage: ValueSource {
    public func valueFor(identifier: StorageID) -> Stored? {
        storage[identifier]
    }
}

extension InMemoryStorage: ValueStorage {
    public func store(value: Stored, identifier: StorageID) {
        storage[identifier] = value
    }

    public func removeValueFor(identifier: StorageID) {
        storage.removeValue(forKey: identifier)
    }
}

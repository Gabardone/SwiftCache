//
//  ReadOnlyStorage.swift
//
//
//  Created by Óscar Morales Vivó on 4/22/23.
//

import Foundation

/**
 A protocol for asynchronous, failable access to data by an identifier.

 Caches that fetch data from storage should use a façaded `ReadOnlyProvider` to perform those operations as to allow
 for testability and overall abstract away hard dependencies on storage APIs (DBs, network, file system…).
 */
public protocol ReadOnlyStorage<Stored, StorageID> {
    /**
     The type used for storage.
     */
    associatedtype Stored

    /**
     Type used to identify a stored value.
     */
    associatedtype StorageID: Hashable

    /**
     returns the stored value, if any, for the given `identifier`.

     The method will return `nil` if the value is not found in storage. It may `throw` if some other issue prevents
     value retrieval.
     - Parameter identifier: The identifier to use for data retrieval. Must be unique and stable.
     - Returns: The value fetched from local persistence, or `nil` if none can be found in storage for `identifier`.
     */
    func storedValueFor(identifier: StorageID) async throws -> Stored?
}

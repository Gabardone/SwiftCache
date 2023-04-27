//
//  Storage.swift
//
//
//  Created by Óscar Morales Vivó on 4/23/23.
//

import Foundation

/**
 A protocol for asynchronous, failable storage of data by identifier.

 This is the mutable extension of `ReadOnlyStorage` to be used for `ChainableCache` implementations to store the
 results of its `next` cache fetch.

 Caches that either store or manage raw data should store a façaded existential `any Storage` with the right types to
 perform those operations as to allow for testability and overall abstract away hard dependencies on storage APIs (DBs,
 network, file system…).
 */
public protocol Storage<Stored, StorageID>: ReadOnlyStorage {
    /**
     Stores the given data locally for the given `identifier`

     There are no guarantees that storage will work or that it will remain in place for long, but a cache chain will
     still attempt to store any found value in its previous links for faster access on a subsequent request.
     - Parameter value: The image data.
     - Parameter identifier: An identifier that uniquely identifies the value to store for later retrieval.
     */
    func store(value: Stored, identifier: StorageID) async throws

    /**
     Removes the value for the given identifier, if found.

     The method will just return if the value is not in storage. And it will throw if removal failes (i.e. file storage
     deletion fails).
     - Parameter identifier: An identifier that uniquely identifies the value we want to remove.
     */
    func removeValueFor(identifier: StorageID) async throws
}
